# Сборка базы из исходников

1. Создать пустую базу 1С без конфигурации, открыть её в режиме Конфигуратора.
2. Загрузить в созданную базу конфигурацию из каталога src/. Для этого в Конфигураторе выбрать пункт меню *Конфигурация* / *Загрузить конфигурацию из файлов...*, указать путь к каталогу src/, например "F:\fa\src" или "/tmp/fa/src", и нажать кнопку "*Выполнить*".
3. Сохранить конфигурацию базы данных (F7), открыть базу в режиме Предприятие.
4. В режиме Предприятие открыть обработку "*[Выгрузка и загрузка данных XML.epf](https://its.1c.ru/db/metod8dev#content:4126)*", на закладке "*Загрузка*" нажать кнопку "*Загрузить данные*" и выбрать файл data/data_for_uploadtoxml.xml.
5. Готово!  