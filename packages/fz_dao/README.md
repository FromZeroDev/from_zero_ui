# fz_dao

A Data Access Objects (this is an AWFUL name, it should be called Forms or something) system with built-in CRUD, form fields, validation, and table integration. Combined with `fz_table`, this is the most powerful subsystem in FromZero UI.

## Core concepts

- **`DAO<T>`** — A Data Access Object that manages a model instance with fields, validation, and save/delete operations
- **Fields** — `StringField`, `NumField`, `DateField`, `BoolField`, `ComboField`, `FileField`, `ListField`
- **FieldGroups** — Organize fields into primary/secondary groups for the UI
- **Validators** — Built-in validators like `fieldValidatorRequired`, `fieldValidatorNumberNotZero`, or custom lambdas
- **LazyDAO** — Populate a DAO's fields lazily from an original model

## Usage example

```dart
class ContainerDAO extends LazyDAO<ContainerFull> {
  ContainerDAO(super.originalModel);

  @override
  void buildDAO() => initialize(
    id: originalModel?.id,
    uiNameGetter: (dao) => 'Container ${numeroContainer(dao)}',
    classUiNameGetter: (dao) => 'Container',
    onSave: (context, e) => buildModel(e),
    fieldGroups: [
      FieldGroup(fields: {
        'numero': StringField(
          value: originalModel?.numero,
          uiNameGetter: (field, dao) => 'Number',
          tableColumnWidth: 122,
          clearableGetter: (field, dao) => false,
          validatorsGetter: (field, dao) => [fieldValidatorRequired],
        ),
        'tipo': ComboField<DAO<ContainerTipo>>(
          value: originalModel?.tipo == null ? null : ContainerTipoDAO(originalModel!.tipo),
          uiNameGetter: (field, dao) => 'Type',
          possibleValuesProviderGetter: (context, field, dao) => tipoProvider.daos,
        ),
        'peso': NumField(
          value: originalModel?.peso,
          uiNameGetter: (field, dao) => 'Weight',
          digitsAfterComma: 3,
          validatorsGetter: (field, dao) => [
            fieldValidatorRequired,
            fieldValidatorNumberNotZero,
            fieldValidatorNumberNotNegative,
          ],
        ),
      }),
    ],
  );

  static ContainerFull buildModel(DAO<ContainerFull> dao) => ContainerFull(
    dao.id ?? -1,
    numero: (dao.props['numero'] as StringField).value ?? '',
    peso: (dao.props['peso'] as NumField).value ?? 0,
  );
}
```

Show form dialog:
```dart
ContainerDAO(null).edit();
```
