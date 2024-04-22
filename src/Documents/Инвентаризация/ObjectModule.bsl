
Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	Движения.ОстаткиТоваров.Записывать = Истина;
	Движения.ОстаткиТоваров.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИнвентаризацияТовары.Номенклатура КАК Номенклатура,
		|	СУММА(ИнвентаризацияТовары.Количество) КАК КоличествоВДокументе,
		|	МАКСИМУМ(ИнвентаризацияТовары.Стоимость) КАК СтоимостьВДокументе
		|ПОМЕСТИТЬ ВТ_Товары
		|ИЗ
		|	Документ.Инвентаризация.Товары КАК ИнвентаризацияТовары
		|ГДЕ
		|	ИнвентаризацияТовары.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ИнвентаризацияТовары.Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ОстаткиТоваровОстатки.Номенклатура КАК Номенклатура,
		|	ОстаткиТоваровОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ПОМЕСТИТЬ ВТ_Остатки
		|ИЗ
		|	РегистрНакопления.ОстаткиТоваров.Остатки(
		|			&Период,
		|			Номенклатура В
		|				(ВЫБРАТЬ
		|					ВТ_Товары.Номенклатура КАК Номенклатура
		|				ИЗ
		|					ВТ_Товары КАК ВТ_Товары)) КАК ОстаткиТоваровОстатки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СебестоимостьСрезПоследних.Номенклатура КАК Номенклатура,
		|	СебестоимостьСрезПоследних.ЦенаЗаЕдиницу КАК ЦенаЗаЕдиницу
		|ПОМЕСТИТЬ ВТ_Себестоимость
		|ИЗ
		|	РегистрСведений.Себестоимость.СрезПоследних(
		|			&Период,
		|			Номенклатура В
		|				(ВЫБРАТЬ
		|					ВТ_Товары.Номенклатура КАК Номенклатура
		|				ИЗ
		|					ВТ_Товары КАК ВТ_Товары)) КАК СебестоимостьСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Товары.Номенклатура КАК Номенклатура,
		|	ВТ_Товары.КоличествоВДокументе КАК КоличествоВДокументе,
		|	ВТ_Товары.СтоимостьВДокументе КАК СтоимостьВДокументе,
		|	ВТ_Остатки.КоличествоОстаток КАК Остаток,
		|	ВТ_Себестоимость.ЦенаЗаЕдиницу КАК ЦенаЗаЕдиницу,
		|	ВТ_Товары.КоличествоВДокументе - ВТ_Остатки.КоличествоОстаток КАК Разница
		|ИЗ
		|	ВТ_Товары КАК ВТ_Товары
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Остатки КАК ВТ_Остатки
		|		ПО ВТ_Товары.Номенклатура = ВТ_Остатки.Номенклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Себестоимость КАК ВТ_Себестоимость
		|		ПО ВТ_Товары.Номенклатура = ВТ_Себестоимость.Номенклатура";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Период", МоментВремени());
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Движения.ОстаткиТоваров.Записывать = Истина;
	Движения.Себестоимость.Записывать = Истина;
	
	Пока Выборка.Следующий() Цикл
		Если Выборка.Разница <> 0 Тогда
			Если Выборка.Разница > 0 Тогда
				Движение = Движения.ОстаткиТоваров.ДобавитьПриход();				
			Иначе
				Движение = Движения.ОстаткиТоваров.ДобавитьРасход();							
			КонецЕсли;
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Разница = ? (Выборка.Разница < 0, -Выборка.Разница, Выборка.Разница);
			Движение.Количество = Разница;
		КонецЕсли;
	КонецЦикла;
	
	Если Выборка.СтоимостьВДокументе <> Выборка.ЦенаЗаЕдиницу Тогда
		
		Движение = Движения.Себестоимость.Добавить();
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.ЦенаЗаЕдиницу = Выборка.СтоимостьВДокументе;
		
	КонецЕсли;
	
КонецПроцедуры
