/*
 * Примечания:
 * - Код разбит по модулям, каждый из которых объявляется и инициализируется
 *   в переменной modules. Методы именуются в змеином стиле, при этом
 *   приватные начинаются с подчёркивания.
 *
 *   В силу отсутствия адекватной реализации приватных методов в Typst
 *   приватность --- лишь условное соглашение: такие методы не предназначены
 *   для вызова извне, хотя фактически такая возможность имеется.
 *   Не делайте так!
 *
 * - Чтобы не засорять кодовую базу, строковые константы вынесены в
 *   переменную strings.
 */


#let strings = (
	title: (
		minobrnauki: "МИНОБРНАУКИ РОССИИ\nФедеральное государственное бюджетное образовательное учреждение\nвысшего образования\n",
		sgu: "«САРАТОВСКИЙ НАЦИОНАЛЬНЫЙ ИССЛЕДОВАТЕЛЬСКИЙ
ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ
ИМЕНИ Н. Г. ЧЕРНЫШЕВСКОГО»\n",
		city: "Саратов",
	),
	caps_headings: (
		[Содержание],
		[Введение],
		[Заключение],
		[Список использованных источников],
		[Определения, обозначения и сокращения],
		[Обозначения и сокращения]
	),
	error: (
		no_sex: [*6.21 КоАП РФ*],
		undefined_spec: [*НЕИЗВЕСТНАЯ СПЕЦИАЛЬНОСТЬ*]
	)
)
// Переменная отвечающая за размер отступа красной строки
#let indent = 1.25cm
#let styled = [#set text(red)].func()
#let space = [ ].func()
#let sequence = [].func()


#let modules = (
	/*
	 * Модуль титульного листа
	 * Здесь происходит генерация титульного листа и
	 * определяются все необходимые для этого методы.
	 * Поскольку его создание --- задача не такая уж
	 * и тривиальная, здесь есть много приватных методов
	 * и ваш покорный слуга ещё раз напоминает о
	 * нежелательности их вызова извне. Если такая необходимость
	 * всё же возникает, лучше переименовать метод и убрать
	 * подчёркивание: впоследствии это можно будет хотя бы как-то
	 * отладить.
	 * 
	 * Изначально задумывалось, что единственный доступный
	 * для вызова извне метод --- make, а в остальных не 
	 * должно возникнуть необходимости.
	 */
	title: (
		/*
		 * Отвечает за вывод названия министерства и
		 * университета на титульном листе
		 */
		_default_header:
			() => {
				set align(center)
				// set text(font: "Tempora")
				text(strings.title.minobrnauki)
				v(0.2em)
				text(weight: "bold", strings.title.sgu)
				set align(left)
			},
		/*
		 * Отвечает за вывод тела титульного листа:
		 * заголовок (название работы, если не определено иное),
		 * тип работы, информация об авторе
		 * 
		 * Информация о проверяющем преподавателе
		 * генерируется не здесь по историческим причинам.
		 */
		_default_body:
			(data) => {
				set align(center)
				v(3cm)
				text(weight: "bold", upper(data.title))
				v(1.5cm)
			},
		/*
		 * Отвечает за вывод города и года на титульном листе
		 */
		_default_footer:
			() => {
				v(1fr)
				set align(center)
				text(strings.title.city + " " + str(datetime.today().year()))
			},

		/*
		 * Получает заголовок титульного листа.
		 * Принимает:
		 *  - info - информация о документе
		 * Возвращает:
		 *  - В зависимости от типа:
		 *    - Тему работы, если это не автореферат и не отчёт по НИРу
		 *    - В противном случае названия соответствующих типов работ
		 */
		_get_title_string:
			(info) => {
				if info.type == "autoref" {
					return [АВТОРЕФЕРАТ]
				}
				if info.type == "nir" {
					return [ОТЧЁТ О НАУЧНО-ИССЛЕДОВАТЕЛЬСКОЙ РАБОТЕ]
				}
				return info.at("title", default: [Тема работы])
			},
		/*
		 * Генерирует строки текста для вывода на титульном листе
		 * Принимает:
		 *  - info - информация о документе
		 * Возвращает:
		 *  - Словарь:
		 *     title: Заголовок
		 *     worktype: Тип работы
		 *     group: студент(а|ки|ов) s курса sex группы
		 *     specialty: направления 69.14.88 --- Специальность
		 *     faculty: факультета XXX
		 *     author: автор(ы)? работы
		 */
		_get_strings:
			(self, info) => {
				let author = info.at("author", default: (:))
				let title_string = (self.title._get_title_string)(info)
				let faculty_string = "факультета " + author.faculty
				return (
					title: title_string,
					faculty: faculty_string,
					author: author.name
				)
			},
		/*
		 * Генерирует титульный лист
		 * Принимает:
		 *  - info - информация о документе
		 */
		make:
			(self, info) => {
				let strs = (self.title._get_strings)(self, info)
				(self.title._default_header)()
				(self.title._default_body)(strs)
				v(1fr)
				(self.title._default_footer)()
			},
	),

	/*
	 * Модуль генерации документа
	 * Здесь содержатся методы, влияющие на вид всего
	 * документа в целом. Главный из них --- make ---
	 * вызывается из точки входа в стилевой файл и
	 * отвечает за всё оформление выходного документа.
	 */
	document: (
		apply_heading_styles:
			(it) => {
				set text(size: 14pt)
				if it.depth == 1 {
					v(4.3pt * (3 + 1 - 0.2))
				}
				if strings.caps_headings.contains(it.body) {
					set align(center)
					//counter(heading).update(i => i - 1)
					upper(it.body)
				} else {
					it
				}
				v(4.3pt * (0.4 + 0.2))
			},
		/*
		 * Генерирует страницу содержания
		 * Принимает:
		 *  - info - информация о документе
		 */
		make_toc:
			(
				info: ()
			) => {
				show outline.entry.where(
					level: 1
				): it => {
					let heading = it.at("element", default: (:)).at("body", default: "")
					if not strings.caps_headings.contains(heading) {
						it
						return
					}
					grid(
						columns: (auto,1pt, 1fr,1pt, auto),
						align: (left, center, right),
						row-gutter: 0pt,
						rows: (auto),
						inset: 0pt,
						heading, none, it.fill, none, it.page()
					)
				}	
				pagebreak(weak: true)
				outline(indent: 2%, title: [Содержание])
			},
		/*
		 * Генерирует весь документ
		 * Принимает:
		 *  - info - информация о документе
		 *  - doc  - содержимое документа
		 */
		make:
			(
				self,
				info: (),
				settings,
				doc
			) => {
				set page(
					paper: "a4",
					margin: (
						top: 2cm,
						bottom: 2cm,
						left: 2.5cm,
						right: 1.5cm
					)
				)
				set text(
					size: 14pt
				)

				if settings.title_page.at("enabled", default: true) {
					(self.title.make)(self, info)	
				}
				set align(left)

				
				show heading: self.document.apply_heading_styles
				
				set par(
				  // Выравнивание по ширине
					justify: true,
				  // отвечает за красные строки там, где их нет, но они должны быть
          first-line-indent: (amount: indent, all: true),
				)

				// Вывод содержания
				if settings.contents_page.enabled {
					(self.document.make_toc)(info: info)
				}

				// Оформление элементов содержимого документа
				set heading(numbering: "1.1")
				set page(footer: context [
					#h(1fr)
					#counter(page).display(
						"1"
					)
				])
				set page(numbering: "1")
				// set math.equation(numbering: "(1)", supplement: [])
				set figure(supplement: "Рис.")
				set quote(block: true)

				// Вывод самого документа
				doc
			},
	),

	/*
	 * Помощник
	 * Модуль-помощник не содержит особой
	 * функциональности и не имеет конкретного
	 * назначения, но содержащиеся в нём методы
	 * могут быть полезны где угодно и не 
	 * привязаны к конкретной части документа
	 */
	utils: (
		/*
		 * Склеивает строки, игнорируя пустые
		 * Принимает:
		 *  - divider - разделитель (по умолчанию пробел)
		 *  - соединяемые строки в неограниченном количестве
		 * Примечание: метод похож по своей сути
		 * на join, но отличается от него наличием проверки
		 * на пустые строки: рядом с ними разделитель не
		 * ставится, что исключает присутствие двух разделителей
		 * подряд.
		 */
		strglue: 
			(
				divider: " ",
				..strings
			) => {
				let result = ""
				for string in strings.pos() {
					if(
							(result.len() > 0)
						and
							((type(string) != str) or (string.len() > 0))
					) {
						result = result + " "
					}
					// TODO: string было бы неплохо обернуть
					// в str(), но баг в системе типов Typst
					// не позволяет этого сделать
					result = result + string
				}
				return result
			}
	)
)

/*
 * Точка входа, просто вызывает modules.document.make
 */
#let conf(
	title: none,
	info: (),
	type: "referat",
	settings: (),
	doc
) = {
	info.title = title
	info.type = type
	settings.title_page = settings.at("title_page", default: (:))
	(modules.document.make)(modules, info: info, settings, doc)
}
