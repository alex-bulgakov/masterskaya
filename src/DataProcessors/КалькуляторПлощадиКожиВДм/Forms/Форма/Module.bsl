
&НаКлиенте
Процедура РасчитатьПлощадь(Команда)
	
	ШиринаДм = ШиринаМатериала / 100;
	ДлинаДм = ДлинаМатериала / 100;
	Результат = ШиринаДм * ДлинаДм;
	
	Оповестить("РезультатПосчитан", Результат, ЭтотОбъект);
	
КонецПроцедуры
