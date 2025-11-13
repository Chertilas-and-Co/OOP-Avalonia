= Что такое стили?

Стили в Avalonia --- это инструмент для настройки внешнего вида и поведения элементов управления, который аналогичен CSS в веб-разработке, но со своими особенностями.

== Как создать стиль?

XAML стиля имеет две части: атрибут селектора и одно или несколько его свойств с необходимыми значениями.

Задать стиль можно несколькими способами:

1. Внутри AXAML окна в <Window.Styles>. Данный способ является локальным. Стиль применится к конкретному окну.

```axaml
<Window>
  <Window.Styles>
    <Style Selector="...">
      <Setter Property="..." Value="..."/>
    </Style>
  </Window.Styles>
</Window>
```

2. Глобально через файл App.axaml. В файле можно определить общие стили для всего приложения.

```axaml
<Application ...>
    <Application.Styles>
        <Style Selector="...">
            <Setter Property="..." Value="..."/>
        </Style>
    </Application.Styles>
</Application>

```

Также в файле можно определять стили для элементов, при этом не применяя их ко всем элементам управления данного типа.

Например, в App.axaml определен следующий стиль:

```axaml
<Style Selector="Button.login"/>
```

А в MainWindow.axaml созданы две кнопки. Стиль задается за счет указания свойства "Classes".

```axaml
<Button Name="button1" Classes="login"/>
<Button Name="button2"/>
```

Стиль будет применен только к кнопке с наименованием "button1".

3. Через ресурсы ResourceDictionary


== Стили для окон приложения (Window)

Пример создания стиля для окна (Window)

```axaml
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
- Свойство WindowStartupLocation определяет начальное расположение окна на экране.
- Opacity --- свойство, которое задает прозрачность окна.
- CanResize --- свойство, которое задает возможность изменять размер окна. Может иметь значение "True" или "False".
- CanMinimize --- свойство, аналогичное предыдущему. Оно разрешает или запрещает сворачивание окна.
- CanMaximize --- разрешает или запрещает максимизацию окна.

== Стили для кнопок (Button)

```axaml
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

```axaml
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
- FontSize --- свойство, задающее размер шрифта текста.
- TextDecorations --- визуальное укращение текста.
  - "Underline" --- подчеркивание текста.
  - "Overline" --- линия над текстом.
  - "Strikethrough" --- зачеркивание текста.
- TextAlignment --- свойство, задающее выравнивание текста внутри блока.
- Padding --- свойство, которое задает внутренние отступы вокруг текста.
