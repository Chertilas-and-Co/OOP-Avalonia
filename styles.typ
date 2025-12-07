#import "conf/conf.typ" : conf
#show: conf.with(
  type: "pract",
  info: (
      author: (
        name: [],
        faculty: [],
        group: "",
        sex: ""
      ),
      inspector: (
        degree: "",
        name: ""
      )
  ),
  settings: (
    title_page: (
      enabled: false
    ),
    contents_page: (
      enabled: true
    )
  )
)
= Что такое стили?

Стили в Avalonia --- это инструмент для настройки внешнего вида и поведения элементов управления, который аналогичен CSS в веб-разработке, но со своими особенностями. Avalonia использует XAML-подобный язык.

== Как создать стиль?

XAML-стиль состоит из двух основных частей: 
    - атрибут селектора, который указывает, к каким элементам применять стиль
    - набор свойств с необходимыми значениями.

Селектор в Avalonia может содержать тип элемента, класс, а также псевдоклассы --- что позволяет гибко выбирать элементы по различным признакам.

Задать стиль можно несколькими способами:

1. Внутри AXAML окна в \<Window.Styles\>. Данный способ является локальным. Стиль применится к конкретному окну. Приоритет локального стиля выши приоритета глобального.

```xaml
<Window>
  <Window.Styles>
    <Style Selector="...">
      <Setter Property="..." Value="..."/>
    </Style>
  </Window.Styles>
</Window>
```

2. Глобально через файл App.axaml. В файле можно определить общие стили для всего приложения.

```xaml
<Application ...>
    <Application.Styles>
        <Style Selector="...">
            <Setter Property="..." Value="..."/>
        </Style>
    </Application.Styles>
</Application>

```

Также в файле можно определять стили для элементов, при этом не применяя их ко всем элементам управления данного типа, т.е. использовать классы.

Например, в App.axaml определен следующий стиль:

```xaml
<!--login это класс-->
<Style Selector="Button.login"/>
```

А в MainWindow.axaml созданы две кнопки. Стиль задается за счет указания свойства "Classes".

```xaml
<Button Name="button1" Classes="login"/>
<Button Name="button2"/>
```

Стиль будет применен только к кнопке с наименованием "button1".

3. Через ресурсы ResourceDictionary


== Стили для окон приложения (Window)

Пример создания стиля для окна (Window)

```xaml
<Style Selector="Window">
    <Setter Property="Background" Value="#5E4BD8"/>
    <Setter Property="Foreground" Value="White"/>
    <Setter Property="WindowStartupLocation" Value="CenterScreen"/>
    <Setter Property="Opacity" Value="0.8"/>
    <Setter Property="CanResize" Value="False"/>
    <Setter Property="CanMinimize" Value="False"/>
    <Setter Property="CanMaximize" Value="True"/>
</Style>
```

- Selector="Window" --- это значит, что стиль будет применяться ко всем окнам приложения, если они не имеют перекрывающих локальных значений.
- Property отвечает за наименование свойства, которому будет задано значение Value.

Свойства:

- Background --- свойство, отвечающее за фоновый цвет окна. Его можно задать, указав цвет:
  - с помощью наименования ("White", "Red")
  - в шестнадцатеричной форме ("\#5E4BD8")
  - через rgb ("rgb(188, 184, 218)")
- Foreground --- свойство, отвечающее за цвет текста. Оно задается аналогично свойству Background.
- WindowStartupLocation --- определяет начальное расположение окна на экране. Свойство уникально.
- Opacity --- свойство, которое задает прозрачность окна.
- CanResize --- свойство, которое задает возможность изменять размер окна. Может иметь значение "True" или "False". Свойство уникально.
- CanMinimize --- свойство, аналогичное предыдущему. Оно разрешает или запрещает сворачивание окна. Свойство уникально.
- CanMaximize --- разрешает или запрещает максимизацию окна. Свойство уникально.

== Стили для кнопок (Button)

```xaml
<Style Selector="Button.login">
    <Setter Property="Background" Value="#514ED9"/>
    <Setter Property="Foreground" Value="White"/>
    <Setter Property="BorderBrush" Value="#7573D9"/>
    <Setter Property="BorderThickness" Value="2"/>
    <Setter Property="CornerRadius" Value="6"/>
    <Setter Property="Margin" Value="10, 10"/>
    <Setter Property="FontSize" Value="30"/>
</Style>
```

Свойства:

- BorderBrush --- свойство, которое задает цвет рамки кнопки. Значение может определяться аналогично Foreground и Background.
- BorderThickness --- свойство, задающее толщину рамки кнопки.
- CornerRadius - радиус скругления углов кнопки.
- Margin --- свойство, задающее отступы кнопки с четырех сторон. Способы задания:
  - Margin = "10" (одинаковый отступ слева, сверху, справа, снизу).
  - Margin = "5, 10" (первое значение - отступ слева и справа, второе - сверху и снизу)
  - Margin = "0, 5, 10, 15" (отступы определяются в следующем порядке: слева, сверху, справа, снизу)

== Стили для TextBlock

```xaml
<Style Selector="TextBlock">
    <Setter Property="Text" Value="Hello, World!"/>
    <Setter Property="FontSize" Value="28"/>
    <Setter Property="TextDecorations" Value="Underline"/>
    <Setter Property="TextAlignment" Value="Center"/>
    <Setter Property="Padding" Value="5"/>
</Style>
```

Свойства:

- Text --- свойство задает текстовое содержимое элемента.
- FontSize --- свойство, задгающее размер шрифта текста.
- TextDecorations --- визуальное укращение текста.
  - "Underline" --- подчеркивание текста.
  - "Overline" --- линия над текстом.
  - "Strikethrough" --- зачеркивание текста.
- TextAlignment --- свойство, задающее выравнивание текста внутри блока.
- Padding --- свойство, которое задает внутренние отступы вокруг текста.

== Стили для TextBox

```xaml
<Style Selector="TextBox.name">
    <Setter Property="Watermark" Value="имя"/> 
    <Setter Property="IsReadOnly" Value="False"/>
</Style>
```

Свойства:
- Watermark --- свойство, отвечающее за текст-подсказку. Оно отображается, когда элемент пуст. Уникально для TextBox, однако некоторые другие элементы имеют аналог.
- IsReadOnly --- свойство, которое при значении "True", делает элемент доступным только для чтения. Данное свойство есть не у всех элементов управления, а только у тех, которые предназначены для прямого текстового ввода или редактирования данных таким образом.

== Стили для границ (Border)

```xaml
<Style Selector="Border.styleOne">
    <Setter Property="Height" Value="100"/>
    <Setter Property="Width" Value="100"/>
</Style>
```

Свойства:

- Width --- свойство, задающее ширину элемента.
- Height --- свойство, которое определяет высоту элемента.


== Стили для StackPanel

```xaml
<Style Selector="StackPanel.styleTwo">
    <Setter Property="Orientation" Value="Horizontal"/>
    <Setter Property="Spacing" Value="10"/>
</Style>
```

Свойства:

- Orientation --- свойство, задающее ориентацию элемента. Данное свойство уникально для элементов управления, отвечающих за упорядочивание элементов.
    - "Vertical" - вертикальная ориентация (по умолчанию).
    - "Horizontal" - горизональная ориентация.
- Spacing --- свойство, задающее отступы между дочерними элементами управления. Данное свойство также как и Orientation уникально для вышеуказанной группы элементов.

= Что такое псевдоклассы?

Выше были рассмотрены примеры стилей для самых распространенных элементов управления. Приведенные свойства являются общими для элементов управления (если не указано иное).

Теперь, когда вы можете сами написать стиль или класс стиля, рассмотрим псевдоклассы.

Псевдоклассы --- это селекторы, которые выбирают элементы, находящиеся в специфическом состоянии. Обычно они используются вместе с селекторами, для обработки разных состояний.

Например,

```xaml
<Style Selector="CheckBox.styleThree"
    <Setter Property="Background" Value="White"/>
</Style>
<Style Selector="CheckBox.styleThree:checked">
    <Setter Property="Background" Value="#514ED9"/>
 </Style>
```

Первый блок Style задает базовое состояние CheckBox, а второй рассматривает CheckBox в состоянии checked (когда он зажат). В данном случае меняется только цвет фона, однако вы можете менять самые разные свойства.

Примеры часто используемых псевдоклассов в Avalonia:
    - :checked --- для выбранных элементов. Применяется для CheckBox и RadioButton.
    - :pointerover --- псевдокласс, срабатывающий при наведении курсора.
    - :pressed --- срабатывает при нажании кнопки мыши.
    - :disable --- псевдокласс для неактивных элементов.

