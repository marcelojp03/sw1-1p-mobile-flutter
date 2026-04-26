import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/tasks/entities/task_models.dart';
import 'package:sw1_p1/features/tasks/providers/tasks_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/custom_filled_button.dart';
import 'package:sw1_p1/shared/widgets/custom_input_field.dart';
import 'package:sw1_p1/shared/widgets/loading_widget.dart';
import 'package:sw1_p1/shared/widgets/modern_toast.dart';

class ClientTaskScreen extends ConsumerStatefulWidget {
  final String taskId;
  const ClientTaskScreen({super.key, required this.taskId});

  @override
  ConsumerState<ClientTaskScreen> createState() => _ClientTaskScreenState();
}

class _ClientTaskScreenState extends ConsumerState<ClientTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formValues = {};
  final List<PlatformFile> _selectedFiles = [];
  String? _notes;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  TextEditingController _controller(String name) {
    return _controllers.putIfAbsent(name, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final completeState = ref.watch(completeTaskProvider);
    final uploadState = ref.watch(uploadAttachmentsProvider);

    ref.listen<CompleteTaskState>(completeTaskProvider, (prev, next) {
      if (!next.isLoading) {
        if (next.success && prev?.success != true) {
          showModernToast(
            context,
            message: 'Tarea completada con éxito',
            type: ToastType.success,
          );
          ref.invalidate(myTasksProvider);
          ref.read(completeTaskProvider.notifier).reset();
          context.pop();
        } else if (next.error != null && prev?.error != next.error) {
          showModernToast(context, message: next.error!, type: ToastType.error);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Completar Tarea')),
      body: taskAsync.when(
        loading:
            () => const LoadingWidget(useShimmer: true, shimmerItemCount: 4),
        error:
            (e, _) => Center(
              child: Text(
                'Error: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
        data:
            (task) =>
                _buildContent(context, res, task, completeState, uploadState),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Responsive res,
    TaskResponse task,
    CompleteTaskState completeState,
    UploadAttachmentsState uploadState,
  ) {
    final fields = task.formFields;

    return SingleChildScrollView(
      padding: EdgeInsets.all(res.spacing(16)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task header
            _buildHeader(context, res, task),
            SizedBox(height: res.spacing(20)),

            // Dynamic form
            if (fields.isNotEmpty) ...[
              Text(
                'Formulario',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: res.spacing(12)),
              ...fields.asMap().entries.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: res.spacing(12)),
                  child: _buildField(context, res, e.value),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: e.key * 60),
                  duration: 250.ms,
                ),
              ),
              SizedBox(height: res.spacing(8)),
            ],

            // Attachments upload
            _buildAttachmentsSection(context, res, task, uploadState),
            SizedBox(height: res.spacing(16)),

            // Notes
            CustomInputField(
              label: 'Notas (opcional)',
              hint: 'Observaciones adicionales...',
              controller: _notesController,
              maxLines: 3,
            ),
            SizedBox(height: res.spacing(24)),

            // Submit button
            CustomFilledButton(
              text: 'Completar tarea',
              onPressed: () => _handleSubmit(task.id, fields),
              isLoading: completeState.isLoading,
              icon: Icons.check_circle_rounded,
            ),
            SizedBox(height: res.spacing(24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive res, TaskResponse task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(res.spacing(14)),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_late_outlined,
                color: AppTheme.warningColor,
                size: res.iconSize(18),
              ),
              SizedBox(width: res.spacing(8)),
              Expanded(
                child: Text(
                  task.stepName ?? task.title ?? 'Tarea',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: res.fontSize(15),
                  ),
                ),
              ),
            ],
          ),
          if ((task.description ?? '').isNotEmpty) ...[
            SizedBox(height: res.spacing(6)),
            Text(
              task.description!,
              style: TextStyle(
                fontSize: res.fontSize(12),
                color: AppTheme.grey1,
              ),
            ),
          ],
          if (task.formattedDate.isNotEmpty) ...[
            SizedBox(height: res.spacing(4)),
            Text(
              'Creada: ${task.formattedDate}',
              style: TextStyle(
                fontSize: res.fontSize(11),
                color: AppTheme.grey1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    Responsive res,
    FormFieldDescriptor field,
  ) {
    final label = field.label ?? field.name;

    switch (field.type) {
      case 'TEXTAREA':
        return CustomInputField(
          label: label,
          hint: field.placeholder,
          controller: _controller(field.name),
          maxLines: 4,
          validator:
              field.required
                  ? (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
                  : null,
        );

      case 'NUMBER':
        return CustomInputField(
          label: label,
          hint: field.placeholder,
          controller: _controller(field.name),
          keyboardType: TextInputType.number,
          validator:
              field.required
                  ? (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
                  : null,
        );

      case 'DATE':
        return _DateField(
          label: label,
          required: field.required,
          res: res,
          onChanged: (date) => _formValues[field.name] = date.toIso8601String(),
        );

      case 'BOOLEAN':
        return _BooleanField(
          label: label,
          res: res,
          onChanged: (val) => _formValues[field.name] = val,
        );

      case 'SELECT':
        return _SelectField(
          label: label,
          options: field.options ?? [],
          required: field.required,
          res: res,
          onChanged: (val) => _formValues[field.name] = val,
        );

      case 'FILE':
        // FILE type handled in the attachments section
        return const SizedBox.shrink();

      default: // TEXT
        return CustomInputField(
          label: label,
          hint: field.placeholder,
          controller: _controller(field.name),
          validator:
              field.required
                  ? (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
                  : null,
        );
    }
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    Responsive res,
    TaskResponse task,
    UploadAttachmentsState uploadState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(res.spacing(14)),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Archivos adjuntos',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: res.fontSize(13),
                ),
              ),
              TextButton.icon(
                onPressed:
                    uploadState.isLoading
                        ? null
                        : () => _pickAndUpload(task.id),
                icon:
                    uploadState.isLoading
                        ? SizedBox(
                          width: res.iconSize(14),
                          height: res.iconSize(14),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                        : Icon(
                          Icons.attach_file_rounded,
                          size: res.iconSize(16),
                        ),
                label: Text(
                  'Adjuntar',
                  style: TextStyle(fontSize: res.fontSize(12)),
                ),
              ),
            ],
          ),
          // Existing attachments from server
          if (task.attachments.isNotEmpty) ...[
            SizedBox(height: res.spacing(6)),
            ...task.attachments.map(
              (a) => _AttachmentChip(fileName: a.fileName, res: res),
            ),
          ],
          // Local selected files not yet uploaded
          if (_selectedFiles.isNotEmpty) ...[
            SizedBox(height: res.spacing(6)),
            ..._selectedFiles.map(
              (f) => _AttachmentChip(fileName: f.name, res: res, isLocal: true),
            ),
          ],
          if (task.attachments.isEmpty && _selectedFiles.isEmpty)
            Text(
              'Sin archivos adjuntos',
              style: TextStyle(
                fontSize: res.fontSize(11),
                color: AppTheme.grey1,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(String taskId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) return;

      setState(() => _selectedFiles.addAll(result.files));

      final multipartFiles =
          result.files
              .where((f) => f.path != null)
              .map((f) => MultipartFile.fromFileSync(f.path!, filename: f.name))
              .toList();

      if (multipartFiles.isEmpty) return;

      final uploaded = await ref
          .read(uploadAttachmentsProvider.notifier)
          .upload(taskId, multipartFiles);

      if (uploaded != null && mounted) {
        showModernToast(
          context,
          message: 'Archivos subidos correctamente',
          type: ToastType.success,
        );
        ref.invalidate(taskDetailProvider(taskId));
        setState(() => _selectedFiles.clear());
      } else if (mounted) {
        final err = ref.read(uploadAttachmentsProvider).error;
        if (err != null) {
          showModernToast(context, message: err, type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        showModernToast(
          context,
          message: 'Error al seleccionar archivo',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _handleSubmit(
    String taskId,
    List<FormFieldDescriptor> fields,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    // Collect text field values
    for (final field in fields) {
      if (['TEXT', 'TEXTAREA', 'NUMBER'].contains(field.type)) {
        final val = _controllers[field.name]?.text.trim();
        if (val != null && val.isNotEmpty) {
          _formValues[field.name] =
              field.type == 'NUMBER' ? num.tryParse(val) ?? val : val;
        }
      }
    }

    _notes = _notesController.text.trim();

    await ref
        .read(completeTaskProvider.notifier)
        .complete(
          taskId,
          Map<String, dynamic>.from(_formValues),
          notes: _notes?.isEmpty == true ? null : _notes,
        );
  }
}

// ===== Helper widgets =====

class _DateField extends StatefulWidget {
  final String label;
  final bool required;
  final Responsive res;
  final void Function(DateTime) onChanged;

  const _DateField({
    required this.label,
    required this.required,
    required this.res,
    required this.onChanged,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selected ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _selected = picked);
          widget.onChanged(picked);
        }
      },
      child: AbsorbPointer(
        child: CustomInputField(
          label: widget.label,
          hint: 'Seleccionar fecha',
          controller: TextEditingController(
            text:
                _selected == null
                    ? ''
                    : '${_selected!.day}/${_selected!.month}/${_selected!.year}',
          ),
          suffix: const Icon(Icons.calendar_today_outlined),
          validator:
              widget.required
                  ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null
                  : null,
        ),
      ),
    );
  }
}

class _BooleanField extends StatefulWidget {
  final String label;
  final Responsive res;
  final void Function(bool) onChanged;

  const _BooleanField({
    required this.label,
    required this.res,
    required this.onChanged,
  });

  @override
  State<_BooleanField> createState() => _BooleanFieldState();
}

class _BooleanFieldState extends State<_BooleanField> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        widget.label,
        style: TextStyle(fontSize: widget.res.fontSize(13)),
      ),
      value: _value,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
      activeThumbColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SelectField extends StatefulWidget {
  final String label;
  final List<String> options;
  final bool required;
  final Responsive res;
  final void Function(String?) onChanged;

  const _SelectField({
    required this.label,
    required this.options,
    required this.required,
    required this.res,
    required this.onChanged,
  });

  @override
  State<_SelectField> createState() => _SelectFieldState();
}

class _SelectFieldState extends State<_SelectField> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _selected,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.res.spacing(14),
          vertical: widget.res.spacing(12),
        ),
      ),
      items:
          widget.options
              .map(
                (o) => DropdownMenuItem<String>(
                  value: o,
                  child: Text(
                    o,
                    style: TextStyle(fontSize: widget.res.fontSize(13)),
                  ),
                ),
              )
              .toList(),
      onChanged: (v) {
        setState(() => _selected = v);
        widget.onChanged(v);
      },
      validator:
          widget.required
              ? (v) => v == null ? 'Seleccione una opción' : null
              : null,
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final String fileName;
  final Responsive res;
  final bool isLocal;

  const _AttachmentChip({
    required this.fileName,
    required this.res,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: res.spacing(4)),
      padding: EdgeInsets.symmetric(
        horizontal: res.spacing(10),
        vertical: res.spacing(6),
      ),
      decoration: BoxDecoration(
        color: (isLocal ? AppTheme.warningColor : AppTheme.successColor)
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isLocal ? AppTheme.warningColor : AppTheme.successColor)
              .withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocal ? Icons.hourglass_top_rounded : Icons.attachment_rounded,
            size: res.iconSize(14),
            color: isLocal ? AppTheme.warningColor : AppTheme.successColor,
          ),
          SizedBox(width: res.spacing(6)),
          Flexible(
            child: Text(
              fileName,
              style: TextStyle(fontSize: res.fontSize(11)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
