# Прототип конфигурации 1С для фундаментального анализа ценных бумаг и финансового анализа

Прототип конфигурации для расчёта значений произвольных показателей по заданным формулам. Основное назначение - финансовый анализ и фундаментальный анализ ценных бумаг, но, теоретически, может быть использована и для других целей.

Файлы:
* **src/*** - конфигурация, выгруженная в XML-файлы;
* **data/data_for_uploadtoxml.xml** - тестовые данные по нескольким эмитентам (в т.ч. Газпрому, Роснефти, Сбербанку) в формате XML для загрузки с помощью стандартной обработки "Выгрузка и загрузка данных XML.epf"

Подробнее: https://infostart.ru/public/723796/

Краткая документация:
* [Сборка базы из исходников](docs/install.md)
* [Ввод данных отчётности](docs/entering_report_data.md)
* [Ввод данных за отчётный год](docs/entering_annual_data.md)
* [Источники данных](docs/data_sources.md)
