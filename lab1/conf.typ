#import "@preview/ctheorems:1.1.3": *
#import "@preview/zebraw:0.5.5": zebraw, zebraw-init
#import "@preview/subpar:0.2.2"

/*
 * Примечания:
 * - Код разбит по модулям, каждый из которых объявляется и инициализируется
 *   в переменной modules. Методы именуются в змеином стиле, при этом
 *   приватные начинаются с подчёркивания.
 *
 *   В силу отсутствия адекватной реализации приватных методов в Typst
 *   приватность --- лишь условное соглашение: такие методы не предназначены
 *   для вызова извне, хотя фактически такая возможность имеется. Не делайте
 *   так!
 *
 * - Чтобы не засорять кодовую базу, строковые константы вынесены в
 *   переменную strings.
 */


#let strings = (
  title: (
    minobrnauki: "МИНОБРНАУКИ РОССИИ\nФедеральное государственное бюджетное образовательное учреждение\nвысшего образования\n",
    sgu: ["САРАТОВСКИЙ НАЦИОНАЛЬНЫЙ ИССЛЕДОВАТЕЛЬСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ ИМЕНИ Н. Г. ЧЕРНЫШЕВСКОГО"],
    city: "Саратов",
    worktypes: (
      referat: [РЕФЕРАТ],
      coursework: [КУРСОВАЯ РАБОТА],
      diploma: [Выпускная квалификационная работа],
      autoref: [работа],
      nir: [работа],
      pract: [],
    ),
    from_course: "курса",
    from_group: "группы",
    from_speciality: "направления",
  ),
  student: (
    male: "студента",
    female: "студентки",
    plural: "студентов",
  ),
  caps_headings: (
    [ОПРЕДЕЛЕНИЯ, ОБОЗНАЧЕНИЯ И СОКРАЩЕНИЯ],
    [СОДЕРЖАНИЕ],
    [ВВЕДЕНИЕ],
    [ЗАКЛЮЧЕНИЕ],
    [СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ],
  ),
  specialities: (
    spec_kb: [10.05.01 --- Компьютерная безопасность],
    bac_ivt: [09.03.01 --- Информатика и вычислительная техника],
    bac_moais: [02.03.03 --- Математическое обеспечение и администрирование информационных систем],
    bac_fiit: [02.03.02 --- Фундаментальная информатика и информационные технологии],
    bac_pi: [09.03.04 --- Программная инженерия],
    mag_ivt: [09.04.01 --- Информатика и вычислительная техника],
    mag_moais: [02.04.03 --- Математическое обеспечение и администрирование информационных систем],
  ),
  error: (
    no_sex: [*6.21 КоАП РФ*],
    undefined_spec: [*НЕИЗВЕСТНАЯ СПЕЦИАЛЬНОСТЬ*],
  ),
)

// Переменная отвечающая за размер отступа красной строки
#let indent = 1.25cm
#let font_size = 14pt
#let figure_font_size = font_size - 2pt
// #let linespace = font_size
#let line_spacing = 1.75em / 2
#let styled = [#set text(red)].func()
#let space = [ ].func()
#let sequence = [].func()

#let code_font_size = font_size - 4pt
// TODO: надо выяснить сколько нужно приплюсовывать к -indent без хардкода
#let code_block_move = -indent + 11pt

#let code-block-raw(code) = {
  set text(size: code_font_size)
  zebraw(
      lang: false,
      numbering: false,
      code,
  )
}

#let code-block(..args, code) = {
  set text(size: code_font_size)
  move(dx: code_block_move, zebraw(..args, code))
}

#let modules = (
  title: (
    /*
     * Отвечает за вывод названия министерства и
     * университета на титульном листе
     */
    _default_header: () => {
      set align(center)
      // set text(font: "Tempora")
      text(strings.title.minobrnauki)
      v(0.2em)
      text(weight: "bold", strings.title.sgu)
      set align(left)
    },
    /*
     * Отвечает за вывод тела титульного листа: заголовок (название работы,
     * если не определено иное), тип работы, информация об авторе
     *
     * Информация о проверяющем преподавателе генерируется не здесь по
     * историческим причинам.
     */
    _default_body: data => {
      set align(center)
      v(3cm)
      text(weight: "bold", upper(data.title))
      par(data.worktype)
      v(1.5cm)
      set align(left)
    },
    /*
     * Отвечает за вывод города и года на титульном листе
     */
    _default_footer: () => {
      v(1fr)
      set align(center)
      text(strings.title.city + " " + str(datetime.today().year()))
    },
    /*
     * строка "студента такой-то группы" для титульного листа
     */
    // _get_author_string: (self, author) => {
    //   let sex = (self.author_info.get_author_sex)(author)
    //   let course = (self.author_info.get_author_course)(author)
    //   let group = (self.author_info.get_author_group)(author)
    //   if course.len() > 0 {
    //     course = (self.utils.strglue)(course, strings.title.from_course)
    //   }
    //   if group.len() > 0 {
    //     group = (self.utils.strglue)(group, strings.title.from_group)
    //   }
    //   let result = (self.utils.strglue)(sex, course, group)
    //   return result
    // },
    /*
     * получает заголовок титульного листа.
     * принимает:
     *  - info - информация о документе
     * возвращает:
     *  - в зависимости от типа:
     *    - тему работы, если это не автореферат и не отчёт по ниру
     *    - в противном случае названия соответствующих типов работ
     */
    _get_title_string: info => {
      if info.type == "autoref" {
        return [автореферат]
      }
      if info.type == "nir" {
        return [отчёт о научно-исследовательской работе]
      }
      return info.at("title", default: [тема работы])
    },
    /*
     * генерирует строки текста для вывода на титульном листе
     * принимает:
     *  - info - информация о документе
     * возвращает:
     *  - словарь:
     *     title: заголовок
     *     worktype: тип работы
     *     group: студент(а|ки|ов) s курса sex группы
     *     specialty: направления 69.14.88 --- специальность
     *     faculty: факультета xxx
     *     author: автор(ы)? работы
     */
    _get_strings: (self, info) => {
      let author = info.at("author", default: (:))
      let title_string = (self.title._get_title_string)(info)
      let worktype = strings.title.worktypes.at(info.type, default: [])
      let faculty_string = "факультета " + author.faculty
      return (
        title: title_string,
        worktype: worktype,
        faculty: faculty_string,
      )
    },
    /*
     * генерирует титульный лист
     * принимает:
     *  - info - информация о документе
     */
    make: (self, info) => {
      let strs = (self.title._get_strings)(self, info)
      (self.title._default_header)()
      (self.title._default_body)(strs)
      v(1fr)
      (self.title._default_footer)()
    },
  ),
  /*
   * модуль генерации документа здесь содержатся методы, влияющие на вид всего
   * документа в целом. главный из них --- make --- вызывается из точки входа в
   * стилевой файл и отвечает за всё оформление выходного документа.
   */
  document: (
    apply_heading_styles: it => {
      set text(size: font_size)
      if it.depth == 1 {
        pagebreak(weak: true)
      }
      if strings.caps_headings.contains(it.body) {
        align(center, it.body)
      } else {
        pad(left: indent, it)
      }
      v(line_spacing / 2)
    },
    /*
     * генерирует страницу содержания
     * принимает:
     *  - info - информация о документе
     */
    make_toc: (info: ()) => {
      show outline.entry.where(level: 1): it => {
        let heading-text = it
          .at("element", default: (:))
          .at("body", default: "")

        let is-outlined = it.element.outlined
        let is-annex = state("annex", false).at(it.element.location())
        let is-caps = heading-text in strings.caps_headings

        // TODO: Хотелось бы запретить создавать ненумерованные заголовки. По
        // какой-то причине это не срабаотывает для самого заголовка содержания. Не
        // понятно почему оно сюда вообще попадает.
        // assert(is-caps or (not is-outlined) or it.element.numbering != none)

        if (not (is-annex or is-caps)) {
          return it
        }

        assert(is-annex or is-caps)
        let prefix = none
        if is-annex {
          prefix = [ПРИЛОЖЕНИЕ #it.prefix() #heading-text]
        } else if is-caps {
          prefix = heading-text + sym.space
        }
        link(
          it.element.location(),
          it.indented(
            none,
            prefix
              + sym.space
              + box(width: 1fr, it.fill)
              + sym.space
              + sym.wj
              + it.page(),
          ),
        )
      }
      outline(title: [СОДЕРЖАНИЕ])
    },
    /*
     * Генерирует весь документ
     * Принимает:
     *  - info - информация о документе
     *  - doc  - содержимое документа
     */
    make: (self, info: (), settings, doc) => {
      set page(
        paper: "a4",
        margin: (
          top: 2cm,
          bottom: 2cm,
          left: 2.5cm,
          right: 1.5cm,
        ),
      )
      set text(size: font_size, lang: "ru", font: "Times New Roman")

      if settings.title_page.at("enabled", default: true) {
        (self.title.make)(self, info)
      }

      show: thmrules.with(qed-symbol: $square$)
      show heading: self.document.apply_heading_styles
      show raw.where(block: true): code-block-raw

      set par(
        // Выравнивание по ширине
        justify: true,
        // отвечает за красные строки там, где их нет, но они должны быть
        first-line-indent: (amount: indent, all: true),
        leading: line_spacing,
        spacing: line_spacing,
      )

      // Вывод содержания
      if settings.contents_page.enabled {
        (self.document.make_toc)(info: info)
      }

      // Оформление элементов содержимого документа
      set ref(supplement: "")
      set heading(numbering: "1.1", hanging-indent: -indent)
      set page(
        footer: context [
          #h(1fr)
          #counter(page).display("1")
        ],
      )
      set page(numbering: "1")
      // set math.equation(numbering: "(1)")

      set figure.caption(separator: [ -- ])
      show figure.caption: set text(size: figure_font_size)

      show figure.where(kind: table): set figure.caption(position: top)
      show figure.where(kind: table): set text(size: figure_font_size)
      show figure.where(kind: table): set block(breakable: true)
      show figure.caption.where(kind: table): set align(left)

      set terms(separator: [ --- ])

      set quote(block: true)

      set bibliography(title: "СПИСОК ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ")
      set bibliography(style: "gost-7-1-2003.csl")

      // Примерный размер "---". Определено на глаз, как сделать более точным
      // не разбирался.
      // let shift-back-list = 1.5em
      // set list(indent: indent - shift-back-list, marker: [#strong([---])])
      // let shift-back-enum = 1.25em
      // set enum(indent: indent - shift-back-enum)

      // Вывод самого документа
      doc
    },
  ),
  /*
   * Помощник Модуль-помощник не содержит особой функциональности и не имеет
   * конкретного назначения, но содержащиеся в нём методы могут быть полезны
   * где угодно и не привязаны к конкретной части документа
   */
  utils: (
    /*
     * Склеивает строки, игнорируя пустые
     * Принимает:
     *  - divider - разделитель (по умолчанию пробел)
     *  - соединяемые строки в неограниченном количестве
     * Примечание: метод похож по своей сути на join, но отличается от него
     * наличием проверки на пустые строки: рядом с ними разделитель не
     * ставится, что исключает присутствие двух разделителей подряд.
     */
    strglue: (divider: " ", ..strings) => {
      let result = ""
      for string in strings.pos() {
        if (
          (result.len() > 0) and ((type(string) != str) or (string.len() > 0))
        ) {
          result = result + " "
        }
        // TODO: string было бы неплохо обернуть в str(), но баг в системе
        // типов Typst не позволяет этого сделать
        result = result + string
      }
      return result
    },
  ),
)

#let defabbr = {
  heading(
    numbering: none,
    outlined: true,
    [ОПРЕДЕЛЕНИЯ, ОБОЗНАЧЕНИЯ И СОКРАЩЕНИЯ],
  )
}

#let intro = {
  heading(numbering: none, outlined: true, [ВВЕДЕНИЕ])
}


#let conclusion = {
  heading(numbering: none, outlined: true, [ЗАКЛЮЧЕНИЕ])
}

#let annex-letters = "АБВГДЕЖЗИКЛМНПРСТУФХЦШЩЭЮЯABCDEFGHJKLMNPQRSTUVWXYZ"
#let annex-numbering(..nums) = {
  let number = nums.pos().first() - 1
  annex-letters.clusters().at(number, default: str(number))
}

// thx https://github.com/typst-g7-32/modern-g7-32
#let annexes-start(it) = {
  set heading(
    numbering: annex-numbering,
    outlined: true,
  )
  set align(center)

  show heading: it => {
    if it.depth == 1 {
      pagebreak(weak: true)
    }
    set text(size: font_size)
    let letter = counter(heading).display(annex-numbering)
    [ПРИЛОЖЕНИЕ #letter \ #it.body #v(line_spacing / 2)]
  }

  state("annex").update(true)
  counter(heading).update(0)

  it
}

#let thm-format = thmplain.with(
  inset: 0em,
  padding: (y: font_size / 2),
  titlefmt: strong,
  bodyfmt: emph,
  namefmt: x => [(#x)],
  base: none,
  separator: [#strong(".")#h(0.2em)],
)
#let definition = thm-format("definition", "Определение")
#let theorem = thm-format("theorem", "Теорема")
#let proof = thmproof("proof", "Доказательство")

// TODO: по какой-то причине эта функция всегда вставляет пустую строку в конце
#let source-file(file) = {
  raw(read(file), block: true)
}

/*
 * Точка входа, просто вызывает modules.document.make
 */
#let conf(
  title: none,
  info: (),
  type: "referat",
  settings: (),
  doc,
) = {
  info.title = title
  info.type = type
  settings.title_page = settings.at("title_page", default: (:))
  (modules.document.make)(
    modules,
    info: info,
    settings,
    [
      #show: zebraw-init.with(background-color: auto, hanging-indent: true)
      #doc
    ],
  )
}

