﻿
&НаКлиентеНаСервереБезКонтекста
// Разбивает строку на несколько строк по разделителю. Разделитель может иметь любую длину.
//
// Параметры:
//  Строка                 - Строка - текст с разделителями;
//  Разделитель            - Строка - разделитель строк текста, минимум 1 символ;
//  ПропускатьПустыеСтроки - Булево - признак необходимости включения в результат пустых строк.
//    Если параметр не задан, то функция работает в режиме совместимости со своей предыдущей версией:
//     - для разделителя-пробела пустые строки не включаются в результат, для остальных разделителей пустые строки
//       включаются в результат.
//     - если параметр Строка не содержит значащих символов или не содержит ни одного символа (пустая строка), то в
//       случае разделителя-пробела результатом функции будет массив, содержащий одно значение "" (пустая строка), а
//       при других разделителях результатом функции будет пустой массив.
//  СокращатьНепечатаемыеСимволы - Булево - сокращать непечатаемые символы по краям каждой из найденных подстрок.
//
// Возвращаемое значение:
//  Массив - массив строк.
//
// Примеры:
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",") - возвратит массив из 5 элементов, три из которых  - пустые
//  строки;
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",", Истина) - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок(" один   два  ", " ") - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок("") - возвратит пустой массив;
//  РазложитьСтрокуВМассивПодстрок("",,Ложь) - возвратит массив с одним элементом "" (пустой строкой);
//  РазложитьСтрокуВМассивПодстрок("", " ") - возвратит массив с одним элементом "" (пустой строкой);
//
// Примечание:
//  В случаях, когда разделителем является строка из одного символа, и не используется параметр СокращатьНепечатаемыеСимволы,
//  рекомендуется использовать функцию платформы СтрРазделить.
Функция РазложитьСтрокуВМассивПодстрок(Знач Строка, Знач Разделитель = ",", Знач ПропускатьПустыеСтроки = Неопределено, СокращатьНепечатаемыеСимволы = Ложь) Экспорт
	
	Результат = Новый Массив;
	
	// Для обеспечения обратной совместимости.
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда 
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;
	//
	
	Позиция = СтрНайти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Если СокращатьНепечатаемыеСимволы Тогда
				Результат.Добавить(СокрЛП(Подстрока));
			Иначе
				Результат.Добавить(Подстрока);
			КонецЕсли;
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = СтрНайти(Строка, Разделитель);
	КонецЦикла;
	
	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Если СокращатьНепечатаемыеСимволы Тогда
			Результат.Добавить(СокрЛП(Строка));
		Иначе
			Результат.Добавить(Строка);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции 

&НаКлиенте
Процедура Загрузить(Команда)
	
	Дата1 = Период.ДатаНачала;
	Дата2 = Период.ДатаОкончания;
	
	ЗагрузитьНаСервере();
	
	ПоказатьОповещениеПользователя("Загрузка котировок завершена!");
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьНаСервере()
	
	Цены.Очистить();
	
	ТаблицаКотировок = ПолучитьТаблицуКотировок(Дата1, Дата2, Тикер);
	
	Если ТаблицаКотировок = Неопределено Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось прочитать котировки для Тикер = " + Тикер + "!");
		Возврат;
	КонецЕсли; 
	
	Для Каждого СтрокаТаблицыКотировок Из ТаблицаКотировок Цикл
		НоваяСтрока = Цены.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицыКотировок);
	КонецЦикла; 
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуКотировок(ПарамДата1, ПарамДата2, ПарамТикер = "")
	
	ТаблицаКотировок = Новый ТаблицаЗначений;
	ТаблицаКотировок.Колонки.Добавить("Тикер");
	ТаблицаКотировок.Колонки.Добавить("Дата");
	ТаблицаКотировок.Колонки.Добавить("Цена");
	
	// http://export.rbc.ru/free/micex.0/free.fcgi?period=DAILY&tickers=NULL&d1=01&m1=08&y1=2017&d2=10&m2=08&y2=2017&lastdays=9&separator=%2C&data_format=EXCEL&header=1

	Сервер = "export.rbc.ru";
	АдресСтраницы = "/free/micex.0/free.fcgi?period=DAILY&tickers=[ТИКЕР]&d1=[ДД1]&m1=[ММ1]&y1=[ГГГГ1]&d2=[ДД2]&m2=[ММ2]&y2=[ГГГГ2]&separator=%2C&data_format=EXCEL&header=1";
	
	Замены = Новый Соответствие;
	Замены.Вставить("ТИКЕР"	, ?(ПустаяСтрока(ПарамТикер), "NULL", СокрЛП(ПарамТикер)));
	Замены.Вставить("ДД1"	, Формат(ПарамДата1, "ДФ=dd"));
	Замены.Вставить("ММ1"	, Формат(ПарамДата1, "ДФ=MM"));
	Замены.Вставить("ГГГГ1"	, Формат(ПарамДата1, "ДФ=yyyy"));
	Замены.Вставить("ДД2"	, Формат(ПарамДата2, "ДФ=dd"));
	Замены.Вставить("ММ2"	, Формат(ПарамДата2, "ДФ=MM"));
	Замены.Вставить("ГГГГ2"	, Формат(ПарамДата2, "ДФ=yyyy"));
	
	Для Каждого КлючИЗначение Из Замены Цикл
		АдресСтраницы = СтрЗаменить(АдресСтраницы, "[" + КлючИЗначение.Ключ + "]", КлючИЗначение.Значение);
	КонецЦикла; 
	
	УРЛ = "http://" + Сервер + АдресСтраницы;
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
	
	HTTPСоединение = Новый HTTPСоединение(Сервер);
	HTTPЗапрос = Новый HTTPЗапрос(АдресСтраницы);
	HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос, ИмяВременногоФайла);
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Сервер " + Сервер + " вернул код ошибки " + HTTPОтвет.КодСостояния);
		Возврат Неопределено;
	КонецЕсли; 
	
	ЧтениеТекста = Новый ЧтениеТекста;
	ЧтениеТекста.Открыть(ИмяВременногоФайла);
	
	НомСтр = 0;
	
	НомераКолонок = Новый Структура;
	ПолеТикер = "TICKER";
	ПолеДата = "DATE";
	ПолеЦена = "CLOSE";
	
	Пока Истина Цикл
		
		Стр = ЧтениеТекста.ПрочитатьСтроку();
		Если Стр = Неопределено Тогда
			Прервать;
		КонецЕсли; 
		
		НомСтр = НомСтр + 1;
		
		Если ПустаяСтрока(Стр) Тогда
			Продолжить;
		КонецЕсли; 
		
		НачалоСообщенияОбОшибке = "Ошибка формата файла! Строка #" + НомСтр + ": ";
		
		МассивКомпонент = РазложитьСтрокуВМассивПодстрок(Стр, ",");
		
		Если НомСтр = 1 Тогда
			// в первой строке заголовки
			Для Сч = 0 По МассивКомпонент.Количество() - 1 Цикл
				ТекКомпонент = МассивКомпонент[Сч];
				Если ТекКомпонент = ПолеТикер Тогда
					НомераКолонок.Вставить("Тикер", Сч);
				ИначеЕсли ТекКомпонент = ПолеДата Тогда
					НомераКолонок.Вставить("Дата", Сч);
				ИначеЕсли ТекКомпонент = ПолеЦена Тогда
					НомераКолонок.Вставить("Цена", Сч);
				КонецЕсли; 
			КонецЦикла;
			Если НЕ НомераКолонок.Свойство("Тикер") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НачалоСообщенияОбОшибке + " В заголовке не найдено поле " + ПолеТикер + "!");
				Возврат Неопределено;
			КонецЕсли; 
			Если НЕ НомераКолонок.Свойство("Дата") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НачалоСообщенияОбОшибке + " В заголовке не найдено поле " + ПолеДата + "!");
				Возврат Неопределено;
			КонецЕсли; 
			Если НЕ НомераКолонок.Свойство("Цена") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НачалоСообщенияОбОшибке + " В заголовке не найдено поле " + ПолеЦена + "!");
				Возврат Неопределено;
			КонецЕсли; 
		Иначе 
			Если НЕ ЗначениеЗаполнено(МассивКомпонент[НомераКолонок.Цена]) Тогда
				Продолжить;
			КонецЕсли; 
			
			ТекТикер = МассивКомпонент[НомераКолонок.Тикер];
			ТекДата = Дата(СтрЗаменить(МассивКомпонент[НомераКолонок.Дата], "-", ""));
			ТекЦена = Число(МассивКомпонент[НомераКолонок.Цена]);
			
			НоваяСтрока = ТаблицаКотировок.Добавить();
			НоваяСтрока.Тикер = ТекТикер;
			НоваяСтрока.Дата = ТекДата;
			НоваяСтрока.Цена = ТекЦена;
			
			//ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Дата = " + ТекДата + "; Цена = " + ТекЦена);
			
		КонецЕсли; 
		
	КонецЦикла; 
	
	ЧтениеТекста.Закрыть();
	
	УдалитьФайлы(ИмяВременногоФайла);
	
	Возврат ТаблицаКотировок;
	
КонецФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ВидЦен = Справочники.ВидыЦен.Учетная;
	
	Если Параметры.Свойство("Дата1") Тогда
		Дата1 = Параметры.Дата1;
	Иначе 
		Дата1 = НачалоМесяца(ТекущаяДатаСеанса());
	КонецЕсли; 
	
	Если Параметры.Свойство("Дата2") Тогда
		Дата2 = Параметры.Дата2;
	Иначе 
		Дата2 = ТекущаяДатаСеанса();
	КонецЕсли; 
	
	Если Параметры.Свойство("Тикер") Тогда
		Тикер = Параметры.Тикер;
	КонецЕсли; 
	
	ОткрытоВРежимеВыбора = (Параметры.Свойство("ОткрытоВРежимеВыбора") И Параметры.ОткрытоВРежимеВыбора);
	
	Период.ДатаНачала = Дата1;
	Период.ДатаОкончания = Дата2;
	
	ГодКотировок = НачалоГода(ТекущаяДатаСеанса());
	
	Элементы.ГруппаСтраницы.ТекущаяСтраница = ?(ОткрытоВРежимеВыбора, 
		Элементы.СтраницаЗагрузкиВРежимеВыбора,
		Элементы.СтраницаЗагрузкаПоследнихКотировокГода);
	
КонецПроцедуры

&НаКлиенте
Процедура ЦеныВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если ОткрытоВРежимеВыбора И Элемент.ТекущиеДанные <> Неопределено Тогда
		СтандартнаяОбработка = Ложь;
		//Закрыть(Цены[ВыбраннаяСтрока].Цена);
		Закрыть(Элемент.ТекущиеДанные.Цена)
	КонецЕсли; 
	
КонецПроцедуры


&НаСервере
Процедура ЗагрузитьПоследниеКотировкиВыбранногоГодаНаСервере()
	
	ТекДата = ТекущаяДатаСеанса();
	Если НачалоГода(ГодКотировок) < НачалоГода(ТекДата) Тогда
		Дата2 = КонецГода(ГодКотировок);
	Иначе 
		Дата2 = ТекДата;
	КонецЕсли; 
	Дата1 = Дата2 - 30 * 24 * 60 * 60;
	ТаблицаКотировок = ПолучитьТаблицуКотировок(Дата1, Дата2);
	ТаблицаКотировок.Индексы.Добавить("Тикер");
	
	Запрос = Новый Запрос;

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВводПоказателейПоказатели.Ссылка КАК Ссылка,
	|	ВводПоказателейПоказатели.Ссылка.Дата КАК Дата,
	|	ВводПоказателейПоказатели.Ссылка.Контрагент КАК Контрагент
	|ПОМЕСТИТЬ ВТ_ВсеДокументыУстановкиКотировокВыбранногоГода
	|ИЗ
	|	Документ.ВводПоказателей.Показатели КАК ВводПоказателейПоказатели
	|ГДЕ
	|	ВводПоказателейПоказатели.Ссылка.Периодичность В (&ПериодичностьНет, &ПустаяПериодичность)
	|	И ВводПоказателейПоказатели.Ссылка.Дата МЕЖДУ &НачалоГодаКотировок И &КонецГодаКотировок
	|	И ВводПоказателейПоказатели.Ссылка.Проведен
	|	И ВводПоказателейПоказатели.Показатель В(&ПоказателиЦен)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ВсеДокументы.Контрагент КАК Контрагент,
	|	МАКСИМУМ(ВТ_ВсеДокументы.Ссылка) КАК Ссылка
	|ПОМЕСТИТЬ ВТ_ПоследниеДокументыУстановкиКотировокВыбранногоГода
	|ИЗ
	|	ВТ_ВсеДокументыУстановкиКотировокВыбранногоГода КАК ВТ_ВсеДокументы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|			ВТ_ВсеДокументы.Контрагент КАК Контрагент,
	|			МАКСИМУМ(ВТ_ВсеДокументы.Дата) КАК Дата
	|		ИЗ
	|			ВТ_ВсеДокументыУстановкиКотировокВыбранногоГода КАК ВТ_ВсеДокументы
	|		
	|		СГРУППИРОВАТЬ ПО
	|			ВТ_ВсеДокументы.Контрагент) КАК ВложенныйЗапрос
	|		ПО ВТ_ВсеДокументы.Контрагент = ВложенныйЗапрос.Контрагент
	|			И ВТ_ВсеДокументы.Дата = ВложенныйЗапрос.Дата
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ_ВсеДокументы.Контрагент
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Контрагенты.Ссылка КАК Контрагент,
	|	Контрагенты.ТикерАО КАК ТикерАО,
	|	Контрагенты.ТикерАП КАК ТикерАП,
	|	ВТ_ПоследниеДокументы.Ссылка КАК ДокументУстановкиКотировок
	|ИЗ
	|	Справочник.Контрагенты КАК Контрагенты
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ПоследниеДокументыУстановкиКотировокВыбранногоГода КАК ВТ_ПоследниеДокументы
	|		ПО Контрагенты.Ссылка = ВТ_ПоследниеДокументы.Контрагент
	|ГДЕ
	|	НЕ Контрагенты.ЭтоГруппа
	|	И &ДопУсловия";
	Запрос.УстановитьПараметр("ПериодичностьНет"	, Перечисления.Периодичность.Нет);
	Запрос.УстановитьПараметр("ПустаяПериодичность"	, Перечисления.Периодичность.ПустаяСсылка());
	Запрос.УстановитьПараметр("НачалоГодаКотировок"	, НачалоГода(ГодКотировок));
	Запрос.УстановитьПараметр("КонецГодаКотировок"	, КонецГода(ГодКотировок));
	ПоказателиЦен = Новый Массив;
	ПоказателиЦен.Добавить(ПоказательЦенаАО);
	ПоказателиЦен.Добавить(ПоказательЦенаАП);
	Запрос.УстановитьПараметр("ПоказателиЦен"		, ПоказателиЦен);
	
	ДопУсловия = "";
	Если ФлагНеСоздаватьНовыеДокументы Тогда
		ДопУсловия = ?(ПустаяСтрока(ДопУсловия), "", " И ")
			+ "НЕ ВТ_ПоследниеДокументы.Ссылка ЕСТЬ NULL"
	КонецЕсли;
	Если НЕ ПустаяСтрока(ДопУсловия) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ДопУсловия", ДопУсловия);
	Иначе 
		Запрос.УстановитьПараметр("ДопУсловия", Истина);
	КонецЕсли; 	
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Нечего загружать!");
		Возврат;
	КонецЕсли; 
		
	Выборка = РезультатЗапроса.Выбрать();
	Пока Выборка.Следующий() Цикл
		Котировки = Новый Соответствие; 
		ДатаКотировок = Дата(1, 1, 1);
		ПоказателиИТикеры = Новый Соответствие;
		Если ЗначениеЗаполнено(ПоказательЦенаАО) И ЗначениеЗаполнено(Выборка.ТикерАО) Тогда
			ПоказателиИТикеры.Вставить(ПоказательЦенаАО, Выборка.ТикерАО);
		КонецЕсли; 
		Если ЗначениеЗаполнено(ПоказательЦенаАП) И ЗначениеЗаполнено(Выборка.ТикерАП) Тогда
			ПоказателиИТикеры.Вставить(ПоказательЦенаАП, Выборка.ТикерАП);
		КонецЕсли; 
		Для Каждого КлючИЗначение Из ПоказателиИТикеры Цикл
			ТекПоказатель = КлючИЗначение.Ключ;
			ТекТикер = КлючИЗначение.Значение;
			ТЗ = ТаблицаКотировок.Скопировать(Новый Структура("Тикер", ТекТикер));
			Если ТЗ.Количество() > 0 Тогда
				ТЗ.Сортировать("Дата");
				ПоследняяСтрока = ТЗ[ТЗ.Количество() - 1];
				Котировки.Вставить(ТекПоказатель, ПоследняяСтрока.Цена);
				ДатаКотировок = Макс(ДатаКотировок, ПоследняяСтрока.Дата);
			Иначе 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось найти котировки для тикера = " + ТекТикер);
			КонецЕсли; 
		КонецЦикла; 
		Если Котировки.Количество() = 0 ИЛИ (НЕ ЗначениеЗаполнено(ДатаКотировок)) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось получить котировки для контрагента = " + Выборка.Контрагент);
			Продолжить;
		КонецЕсли;
		Если ЗначениеЗаполнено(Выборка.ДокументУстановкиКотировок) Тогда
			ДокОбъект = Выборка.ДокументУстановкиКотировок.ПолучитьОбъект();
		Иначе 
			ДокОбъект = Документы.ВводПоказателей.СоздатьДокумент();
			ДокОбъект.Контрагент = Выборка.Контрагент;
			ДокОбъект.Множитель = 1;
			ДокОбъект.Периодичность = Перечисления.Периодичность.Нет;
			ДокОбъект.Комментарий = "Цена акций" + ?(Дата2 = ТекДата, " текущая", "");
		КонецЕсли; 
		Для Каждого КлючИЗначение Из Котировки Цикл
			ТекПоказатель = КлючИЗначение.Ключ;
			ТекЦена = КлючИЗначение.Значение;
			СтрокаТабЧасти = ДокОбъект.Показатели.Найти(ТекПоказатель, "Показатель");
			Если СтрокаТабЧасти = Неопределено Тогда
				СтрокаТабЧасти = ДокОбъект.Показатели.Добавить();
				СтрокаТабЧасти.Показатель = ТекПоказатель;
			КонецЕсли;
			Если СтрокаТабЧасти.ЗначениеПоказателя <> ТекЦена Тогда
				СтрокаТабЧасти.ЗначениеПоказателя = ТекЦена;
				СтрокаТабЧасти.Комментарий = "# Загружено " + ТекДата;
			КонецЕсли; 
			ТекРазрядность = ОбщегоНазначенияКлиентСервер.ПолучитьРазрядностьДробнойЧасти(СтрокаТабЧасти.ЗначениеПоказателя);
			Если ТекРазрядность > ДокОбъект.РазрядностьДробнойЧасти Тогда
				ДокОбъект.РазрядностьДробнойЧасти = ТекРазрядность;
			КонецЕсли; 
		КонецЦикла;
		Если НачалоДня(ДокОбъект.Дата) <> НачалоДня(ДатаКотировок) Тогда
			ДокОбъект.Дата = ДатаКотировок;
		КонецЕсли; 
		Если ДокОбъект.РазрядностьДробнойЧасти < 2 Тогда
			ДокОбъект.РазрядностьДробнойЧасти = 2; // всегда с копейками
		КонецЕсли; 
		Если ДокОбъект.Модифицированность() Тогда
			ДокОбъект.Записать(РежимЗаписиДокумента.Проведение);
		КонецЕсли; 
	КонецЦикла; 
	
КонецПроцедуры


&НаКлиенте
Процедура ЗагрузитьПоследниеКотировкиВыбранногоГода(Команда)
	
	Отказ = Ложь;
	СтруктураОбязательныхРеквизитов = Новый Структура("ГодКотировок, ПоказательЦенаАО, ПоказательЦенаАП");
	Для Каждого КлючИЗначение Из СтруктураОбязательныхРеквизитов Цикл
		ИмяРеквизита = КлючИЗначение.Ключ;
		Если НЕ ЗначениеЗаполнено(ЭтотОбъект[ИмяРеквизита]) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не задано значение реквизита " + ИмяРеквизита + "!", , , ИмяРеквизита, Отказ);
		КонецЕсли; 
	КонецЦикла; 
	//Если НЕ ЗначениеЗаполнено(ГодКотировок) Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указан Год котировок!", , , "ГодКотировок", Отказ);
	//КонецЕсли; 
	//Если НЕ ЗначениеЗаполнено(ПоказательЦенаАО) И НЕ ЗначениеЗаполнено(ПоказательЦенаАП) Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указан ни один из Показателей Цена АО/АП!", , , "ПоказательЦенаАО", Отказ);
	//КонецЕсли; 
	Если Отказ Тогда
		Возврат;
	КонецЕсли; 
	
	ЗагрузитьПоследниеКотировкиВыбранногоГодаНаСервере();
	
	ПоказатьОповещениеПользователя("Загрузка котировок завершена!");
	
КонецПроцедуры

