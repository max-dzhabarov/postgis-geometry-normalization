# Нормализация полигональной геометрии в PostGIS

Демонстрационный пример триггерной функции PostgreSQL/PostGIS, которая проверяет и нормализует полигональную геометрию перед записью в таблицу.

Решение предназначено для ситуаций, когда данные редактируются из настольной ГИС или поступают из разнородных источников и должны сохраняться в строгом поле `geometry(MultiPolygon, SRID)`.

## Что делает функция

Перед `INSERT` или изменением поля `geom` функция:

1. удаляет координату Z с помощью `ST_Force2D`;
2. проверяет SRID и отклоняет геометрию в другой системе координат;
3. исправляет невалидную геометрию через `ST_MakeValid`;
4. извлекает только полигональные компоненты через `ST_CollectionExtract`;
5. приводит результат к `MultiPolygon` с помощью `ST_Multi`;
6. отклоняет пустой или всё ещё невалидный результат.

Функция не выполняет автоматическое перепроецирование: неожиданная система координат считается ошибкой данных.

## Требования

- PostgreSQL 14 или новее;
- PostGIS 3.x.

## Запуск демонстрации

```bash
psql -d your_database -f sql/01_setup.sql
psql -d your_database -f sql/02_demo.sql
```

В `01_setup.sql` создаются демонстрационная схема, таблица, функция и триггер. В `02_demo.sql` приведены примеры корректной, невалидной и ошибочной геометрии.

## Важные ограничения

- В примере ожидается SRID 3857; для другой таблицы передайте нужный SRID аргументом триггера.
- Поле геометрии должно называться `geom`.
- Автоматическое исправление может изменить структуру сложной геометрии, поэтому результат следует контролировать.
- Решение демонстрационное и должно быть адаптировано к правилам конкретной базы данных.

## Лицензия

MIT License.

---

# Polygon Geometry Normalization in PostGIS

This repository contains a demonstration PostgreSQL/PostGIS trigger function that validates and normalizes polygon geometries before they are stored.

It is intended for workflows where geometries are edited from a desktop GIS or imported from heterogeneous sources and must fit a strict `geometry(MultiPolygon, SRID)` column.

## What the function does

Before an `INSERT` or an update of `geom`, the function:

1. removes the Z coordinate with `ST_Force2D`;
2. validates the SRID and rejects geometries in an unexpected coordinate system;
3. repairs invalid geometries with `ST_MakeValid`;
4. extracts polygonal components with `ST_CollectionExtract`;
5. converts the result to `MultiPolygon` with `ST_Multi`;
6. rejects an empty or still-invalid result.

The function deliberately avoids automatic reprojection: an unexpected coordinate system is treated as a data error.

## Requirements

- PostgreSQL 14 or later;
- PostGIS 3.x.

## Running the demo

```bash
psql -d your_database -f sql/01_setup.sql
psql -d your_database -f sql/02_demo.sql
```

`01_setup.sql` creates the demonstration schema, table, function, and trigger. `02_demo.sql` contains examples of valid, invalid, and rejected geometries.

## Important limitations

- The example expects SRID 3857; pass a different SRID to the trigger for another table.
- The geometry column must be named `geom`.
- Automatic repair can change the structure of complex geometries, so the result should be reviewed.
- This is a demonstration that must be adapted to the rules of a specific database.

## License

MIT License.
