///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭтоУдалениеПомеченныхОбъектов = Параметры.УдалениеПомеченныхОбъектов;
	Если ЭтоУдалениеПомеченныхОбъектов Тогда
		Заголовок = НСтр("ru = 'Не удалось удалить помеченные объекты'");
		Элементы.ТекстСообщенияОбОшибке.Заголовок = НСтр("ru = 'Невозможно выполнить удаление помеченных объектов, т.к. в программе работают другие пользователи:'");
	КонецЕсли;
	
	ПроверитьМонопольныйРежимНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если МонопольныйРежимДоступен Тогда
		Отказ = Истина;
		ВыполнитьОбработкуОповещения(ОписаниеОповещенияОЗакрытии, Ложь);
		Возврат;
	КонецЕсли;
	
	Если ЭтоУдалениеПомеченныхОбъектов Тогда
		СоединенияИБКлиент.УстановитьПризнакЗавершитьВсеСеансыКромеТекущего(Истина);
	КонецЕсли;
	ПодключитьОбработчикОжидания("ПроверитьМонопольныйРежим", 30);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	Если ЭтоУдалениеПомеченныхОбъектов Тогда
		СоединенияИБКлиент.УстановитьПризнакЗавершитьВсеСеансыКромеТекущего(Ложь);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура АктивныеПользователиНажатие(Элемент)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОткрытьСписокАктивныхПользователейЗавершение", ЭтотОбъект);
	ОткрытьФорму("Обработка.АктивныеПользователи.Форма.АктивныеПользователи", , , , , ,
		ОписаниеОповещения,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	ПроверитьМонопольныйРежимНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура АктивныеПользователи2Нажатие(Элемент)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОткрытьСписокАктивныхПользователейЗавершение", ЭтотОбъект);
	ОткрытьФорму("Обработка.АктивныеПользователи.Форма.АктивныеПользователи" , , , , , ,
		ОписаниеОповещения,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	ПроверитьМонопольныйРежимНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗавершитьСеансыИПовторить(Команда)
	
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.Ожидание;
	Элементы.ФормаПовторитьЗапускПрограммы.Видимость = Ложь;
	Элементы.ФормаЗавершитьСеансыИПерезапуститьПрограмму.Видимость = Ложь;
	
	// Задание параметров блокировки ИБ.
	ПроверитьМонопольныйРежим();
	УстановитьБлокировкуФайловойБазы();
	СоединенияИБКлиент.УстановитьРежимЗавершенияРаботыПользователей(Истина);
	ПодключитьОбработчикОжидания("ОжидатьЗавершенияРаботыПользователей", 60);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьЗапускПрограммы(Команда)
	
	ОтменитьБлокировкуФайловойБазы();
	
	Закрыть(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПовторитьЗапускПрограммы(Команда)
	
	Закрыть(Ложь);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОткрытьСписокАктивныхПользователейЗавершение(Результат, ДополнительныеПараметры) Экспорт
	ПроверитьМонопольныйРежим();
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьМонопольныйРежим()
	
	ПроверитьМонопольныйРежимНаСервере();
	Если МонопольныйРежимДоступен Тогда
		Закрыть(Ложь);
		Возврат;
	КонецЕсли;
		
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьКоличествоАктивныхСеансов(Форма)
	
	Если Форма.КоличествоАктивныхСеансов > 0 Тогда
		ТекстГиперссылки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Активные пользователи (%1)'"), 
			Форма.КоличествоАктивныхСеансов);
	Иначе
		ТекстГиперссылки = НСтр("ru = 'Активные пользователи'");
	КонецЕсли;	
	
	Форма.Элементы.АктивныеПользователи.Заголовок = ТекстГиперссылки;
	Форма.Элементы.АктивныеПользователиОжидание.Заголовок = ТекстГиперссылки;
	Форма.Элементы.АктивныеПользователи.РасширеннаяПодсказка.Заголовок = Форма.ОшибкаУстановкиМонопольногоРежима;
	Форма.Элементы.АктивныеПользователиОжидание.РасширеннаяПодсказка.Заголовок = Форма.ОшибкаУстановкиМонопольногоРежима;
	
	Если Форма.КоличествоАктивныхСеансов = 0 И ПустаяСтрока(Форма.ОшибкаУстановкиМонопольногоРежима) Тогда
		Форма.Элементы.ТекстСообщенияОбОшибке.Заголовок = НСтр("ru = 'Другие пользователи уже завершили свою работу:'");
		Форма.Элементы.ПояснениеПоОшибке.Заголовок = НСтр("ru = 'Для продолжения нажмите Повторить.'");
	Иначе	
		Если Форма.ЭтоУдалениеПомеченныхОбъектов Тогда
			ТекстСообщенияОбОшибке = НСтр("ru = 'Невозможно выполнить удаление помеченных объектов, т.к. не удалось завершить работу пользователей:'");
		Иначе	
			ТекстСообщенияОбОшибке = НСтр("ru = 'Невозможно выполнить обновление версии программы, т.к. не удалось завершить работу пользователей:'");
		КонецЕсли;
		Форма.Элементы.ТекстСообщенияОбОшибке.Заголовок = ТекстСообщенияОбОшибке;
		Форма.Элементы.ПояснениеПоОшибке.Заголовок = НСтр("ru = 'Для продолжения необходимо завершить их работу.'");
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьМонопольныйРежимНаСервере()
	
	СеансыИнформационнойБазы = ПолучитьСеансыИнформационнойБазы();
	НомерСеансаТекущегоПользователя = НомерСеансаИнформационнойБазы();
	КоличествоАктивныхСеансов = 0;
	Для Каждого СеансИБ Из СеансыИнформационнойБазы Цикл
		Если СеансИБ.ИмяПриложения = "Designer"
			Или СеансИБ.НомерСеанса = НомерСеансаТекущегоПользователя Тогда
			Продолжить;
		КонецЕсли;
		КоличествоАктивныхСеансов = КоличествоАктивныхСеансов + 1;
	КонецЦикла;
	
	МонопольныйРежимДоступен = Ложь;
	ОшибкаУстановкиМонопольногоРежима = "";
	Если КоличествоАктивныхСеансов = 0 Тогда
		Попытка
			УстановитьМонопольныйРежим(Истина);
		Исключение
			ОшибкаУстановкиМонопольногоРежима = НСтр("ru = 'Техническая информация:'") + " " 
				+ ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;
		Если МонопольныйРежим() Тогда
			УстановитьМонопольныйРежим(Ложь);
		КонецЕсли;
		МонопольныйРежимДоступен = Истина;
	КонецЕсли;	
	ОбновитьКоличествоАктивныхСеансов(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОжидатьЗавершенияРаботыПользователей()
	
	ПродолжительностьЗавершенияРаботыПользователей = ПродолжительностьЗавершенияРаботыПользователей + 1;
	Если ПродолжительностьЗавершенияРаботыПользователей < 8 Тогда
		Возврат;
	КонецЕсли;
	
	ОтменитьБлокировкуФайловойБазы();
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.Информация;
	ОбновитьКоличествоАктивныхСеансов(ЭтотОбъект);
	Элементы.ФормаПовторитьЗапускПрограммы.Видимость = Истина;
	Элементы.ФормаЗавершитьСеансыИПерезапуститьПрограмму.Видимость = Истина;
	ОтключитьОбработчикОжидания("ОжидатьЗавершенияРаботыПользователей");
	ПродолжительностьЗавершенияРаботыПользователей = 0;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьБлокировкуФайловойБазы()
	
	Объект.ЗапретитьРаботуПользователей = Истина;
	Если ЭтоУдалениеПомеченныхОбъектов Тогда
		Объект.НачалоДействияБлокировки = ТекущаяДатаСеанса() + 2*60;
		Объект.ОкончаниеДействияБлокировки = Объект.НачалоДействияБлокировки + 60;
		Объект.СообщениеДляПользователей = НСтр("ru = 'Программа заблокирована для удаления помеченных объектов.'");
	Иначе
		Объект.НачалоДействияБлокировки = ТекущаяДатаСеанса() + 2*60;
		Объект.ОкончаниеДействияБлокировки = Объект.НачалоДействияБлокировки + 5*60;
		Объект.СообщениеДляПользователей = НСтр("ru = 'Программа заблокирована для обновления на новую версию.'");
	КонецЕсли;
	
	Попытка
		РеквизитФормыВЗначение("Объект").ВыполнитьУстановку();
	Исключение
		ЗаписьЖурналаРегистрации(СоединенияИБ.СобытиеЖурналаРегистрации(),
			УровеньЖурналаРегистрации.Ошибка,,, 
			ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ОбщегоНазначения.СообщитьПользователю(ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура ОтменитьБлокировкуФайловойБазы()
	
	РеквизитФормыВЗначение("Объект").ОтменитьБлокировку();
	
КонецПроцедуры

#КонецОбласти
