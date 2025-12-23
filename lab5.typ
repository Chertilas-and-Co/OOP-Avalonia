#import "conf/conf.typ": conf

#show: conf.with(
  title: [= Лабораторная работа №5],
  type: "pract",
  info: (
    author: (
      name: [],
      faculty: [],
      group: "",
      sex: "",
    ),
    inspector: (
      degree: "",
      name: "",
    ),
  ),
  settings: (
    title_page: (
      enabled: true,
    ),
    contents_page: (
      enabled: true,
    ),
  ),
)



= Подготовка к работе

Для начала работы потребуется установить несколько NuGet-пакетов:

1. Avalonia.Ski;
2. SkiaSharp;
3. SkiaSharp.NativeAssets.

Рассмотрим как можно установить эти пакеты в разных системах.

== Visual Studio (только для Windows):

Приведённые ниже действия и скриншоты были выполнены на Visual Studio 2026, но с лёгкостью могут быть воспроизведены на любой другой современной версии Visual Studio.

Во вкладке "Проект" навигационной панели выберите "Управление пакетами NuGet..."

#figure(
  image(
    "lab5_imports/images/NuGet.png",
    width: 80%,
  ),
)

После этого во вкладке "Обзор" напишите в поле поиска необходимые пакеты и установите их.

#figure(
  image(
    "lab5_imports/images/AvaloniaSki.png",
    width: 80%
  )
)

Для разных систем вы должны установить разную версию SkiaSharp.NativeAssets.

- Windows: SkiaSharp.NativeAssets.Win32;
- Linux: SkiaSharp.NativeAssets.Linux; 
- MacOS: SkiaSharp.NativeAssets.macOS.  

#figure(
  image(
    "lab5_imports/images/SkiaSharp.png",
    width: 80%
  )
)

== Bash (любые системы)

Будьте осторожны! 
Может возникнуть конфликт с версией самой Avalonia.
В файле .csproj можно узнать её, чтобы не допустить конфликта. 
Все пакеты Avalonia в проекте должны иметь строго одинаковую версию.

Установите AvaloniaSki с помощью команды:

`dotnet add package Avalonia.Skia --version 11.3.9` 

Затем SkiaSharp:

`dotnet add package SkiaSharp --version 3.119.1` 

 В зависимости от вашей системы установите один из следующих пакетов:
- Windows: `dotnet add SkiaSharp.NativeAssets.Win32`;
- Linux: `dotnet add package SkiaSharp.NativeAssets.Linux`; 
- MacOS: `dotnet add package SkiaSharp.NativeAssets.macOS`.  

Чтобы проверить, что всё корректно добавилось в проект, убедитесь, что в .csproj есть следующие строки:

```xaml
    <PackageReference Include="SkiaSharp" Version="3.119.1" />
    <PackageReference Include="SkiaSharp.NativeAssets.Win32" Version="3.119.1" /> // может отличаться в зависимости от вашей системы
    <PackageReference Include="Avalonia.Skia" Version="11.3.6"/>
```

= Часть 1. Программирование графики

== WM_PAINT

В операционной системе Windows через сообщение с идентификатором `WM_PAINT` операционная система уведомляет приложение о необходимости перерисовать окно, передавая его в функцию отрисовки. Это происходит при перемещении, изменении размера или открытии окна. Приложение должно быть сделано таким образом, чтобы в любой момент времени при поступлении сообщения `WM_PAINT` функция окна могла перерисовать все окно или любую его часть, заданную своими координатами. 

В Avalonia нет прямого аналога `WM_PAINT`.

== SKPaint


В System.Windows.Forms предусмотрен удобный объектно-ориентированный способ, позволяющий приложению при необходимости перерисовывать окно формы в любой момент времени. Когда вся клиентская область окна формы или часть этой области требует перерисовки, форме передается событие `Paint`. В Avalonia прямого аналога события `Paint` нет. Используется механизм наследования и переопределения виртуальных методов. Роль обработчика отрисовки выполняет метод `Render`. Этот метод вызывается графическим ядром Avalonia автоматически каждый раз, когда компонент должен быть визуализирован на экране. Для реализации собственной графики необходимо создать «кастомный контроль». Технически это пользовательский класс, который наследуется от базового системного класса `Avalonia.Controls.Control`. Вместо `PaintEventArgs` в метод передается `DrawingContext` — контекст рисования, предоставляющий доступ к графическим примитивам. Именно наследование от `Control` дает классу место в визуальном дереве приложения и позволяет переопределить метод `Render`. Надо понимать, что это принципы действия в Avalonia без использования SkiaSharp. Фактически, SkiaSharp используется для работы и изменения изображения, которое выводит Avalonia.

Также в Windows существует GDI (Graphics Device Interface) --- интерфейс , предназначенный для представления графических объектов. Объект Graphics представляет поверхность рисования GDI и используется для создания графических изображений. В силу особенностей работы графики создать экземпляр класса Graphics нельзя, поэтому для обхода зачастую используют ссылку на объект для рисования, полученную из параметра `PaintEventArgs`, который передаётся в обработчик события `Paint`.

На базе технологии GDI была разработана GDI+. Это улучшенная среда для 2D-графики, расширенная возможностями сглаживания линий, использования координат с плавающей точкой, градиентной заливки, использованием ARGB-цветов и так далее.

Аналог `PaintEventArgs` в SkiaSharp --- это `SKPaint`. Он содержит полный набор параметров для отрисовки:
- цвет (RGBA);
- стиль заливки/обводки;
- толщина линий;
- сглаживание;
- эффекты пути (пунктир);
- параметры шрифта.

== Пример использования `SKPaint`

```cs
using(SKPaint paint = new SKPaint())
{
    // 1. Цвет через предопределённые константы
    paint.Color = SKColors.Violet;
    
    // 2. Или через RGBA компоненты (0-255)
    paint.Color = new SKColor(128, 0, 128, 255); // полупрозрачный фиолетовый

    // 3. Толщина обводки (пиксели)
    paint.StrokeWidth = 15;

    // 4. Сглаживание краёв
    paint.IsAntialias = true;

    // 5. Стили отрисовки
    paint.Style = SKPaintStyle.Stroke;            // только обводка
    // paint.Style = SKPaintStyle.Fill;           // только заливка
    // paint.Style = SKPaintStyle.StrokeAndFill;  // совмещение

    // 6. Форма концов линий
    paint.StrokeCap = SKStrokeCap.Round;

    // 7. Соединение линий
    paint.StrokeJoin = SKStrokeJoin.Round;

    // 8. Пунктирный эффект
    paint.PathEffect = SKPathEffect.CreateDash(new[] {10f, 5f}, 0);
}
```

== Объект для рисования

Вместо `Graphics` в Avalonia, с подключением SkiaSharp, используется `SKCanvas`. `SKCanvas` представляет собой поверхность для отрисовки фигур, линий, изображений, текста и т.д.

Отличие состоит в том, что объект `Graphics` создать напрямую нельзя, хотя и существует несколько способов получения его экземпляра, а `SKCanvas` можно. 


== Пример использования `SKCanvas`

```cs
using (var skBitmap = new SKBitmap(imageInfo))
using (var canvas = new SKCanvas(skBitmap))
{
    //очистка и установка фонового цвета
    canvas.Clear(SKColors.AliceBlue);
    using(SKPaint paint = new SKPaint())
    {
        paint.Color = SKColors.Violet;
        paint.StrokeWidth = 15;
        paint.Style = SKPaintStyle.Fill;

        //отрисовка круга
        canvas.DrawCircle(50,50,30,paint);
        //отрисовка прямоугольника
        canvas.DrawRect(0,0,50,50,paint);
    }
    //конвертирование SKBitmap в Avalonia Bitmap
    using (var image = SKImage.FromBitmap(skBitmap))
    using (var data = image.Encode(SKEncodedImageFormat.Png, 100))
    using(MemoryStream memoryStream = new MemoryStream(data.ToArray()))
    {
        Bitmap bm =  new Bitmap(memoryStream);
        imageTest.Source = bm;
    }
}
```
Здесь же появляется `SKBitmap`. Он используется как изменяемая растровая поверхность. Фактически представляет собой массив пикселей в памяти (как холст на мольберте). Это основной объект в оперативной памяти, на котором происходит всё рисование. Здесь хранятся математические данные о пикселях. SkiaSharp умеет рисовать только на нём, но Avalonia не умеет показывать его напрямую.

Почему используется цепочка конвертирования: `SKImage.FromBitmap`() $arrow.r$ `Encode`() $arrow.r$ `MemoryStream` $arrow.r$ `Bitmap`()?

Эта цепочка необходима, потому что `SKBitmap` и Avalonia `Bitmap` --- это разные типы, находящиеся в разных библиотеках с разными внутренними представлениями данных:
- `SKImage.FromBitmap`(`skBitmap`) создаёт неизменяемый образ из `SKBitmap`; 
- `image.Encode`(`SKEncodedImageFormat.Png, 100`) кодирует `SKImage` в стандартный формат PNG с качеством 100% (можно выбрать другой формат изображения);
- `data.ToArray()` преобразует `SKData` в массив байтов (`byte[]`). Это необходимо для взаимодействия с `MemoryStream`, а массив байтов --- это самый базовый формат, поддерживаемый всеми платформами;
- `new MemoryStream(byte[])` оборачивает массив байтов в поток в памяти;
- `new Bitmap(memoryStream)`. Конструктор `Bitmap` принимает `Stream`, который он использует для загрузки изображения.

Также можно отрисовывать напрямую с помощью `Bitmap`.

== Пример использования `Bitmap`

```cs
SKImageInfo imageInfo = new SKImageInfo(300,250);
using(SKSurface sKSurface = SKSurface.Create(imageInfo))
{
    SKCanvas canvas = sKSurface.Canvas;
    canvas.Clear(SKColors.AliceBlue)
    using(SKPaint paint = new SKPaint())
    {
        paint.Color = SKColors.Violet;
        paint.StrokeWidth = 15;
        paint.Style = SKPaintStyle.Stroke;
        canvas.DrawCircle(50,50,30,paint);
        canvas.DrawRect(0,0,50,50,paint);
    }
    //конвертирование SKBitmap в Avalonia Bitmap
    using (SKImage image = sKSurface.Snapshot())
    using(SKData data = image.Encode(SKEncodedImageFormat.Png, 100))
    using(MemoryStream memoryStream = new MemoryStream(data.ToArray()))
    {
        Bitmap bm =  new Bitmap(memoryStream);
        imageTest.Source = bm;
    }
}   
```

Рисование также осуществляется слоями, которые перекрывают друг друга.

В Windows Forms используется `PictureBox` для отображения `Bitmap`. В Avalonia для аналогичных целей используется Image контроль. Image --- это визуальный компонент Avalonia, расположенный в пространстве имен `Avalonia.Controls`. Он служит контейнером для отображения графического контента. В отличие от `PictureBox`, он не является инструментом рисования, а лишь визуализирует переданный ему объект типа `IBitmap`. Поскольку библиотека рисования (SkiaSharp) и UI-фреймворк (Avalonia) используют разные типы данных для хранения изображений, необходимо выполнять явное преобразование из рабочего формата `SKBitmap` в отображаемый формат `Avalonia.Media.Imaging.Bitmap`.

Вот как может выглядеть код на axaml:

```xaml
<Image x:Name="imageTest" Width="500" Height="500"/> 
```

== Методы, свойства и классы SkiaSharp

Класс `SKCanvas` содержит методы для рисования различных фигур. На месте методов `DrawEllipse`, `FillEllipse` из GDI+ используются `DrawCircle`, `DrawOval`, `DrawRect` и другие.

Всем методам можно задать стиль с помощью `SKPaint`. У фигур можно отрисовывать как только обводку, так и заливать полностью.

=== Примитивные фигуры на `SKCanvas`

*Заполненная окружность:*

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Red;
    paint.Style = SKPaintStyle.Fill;
    paint.IsAntialias = true; // сглаживание краёв
    canvas.DrawCircle(50, 50, 30, paint);
}
```

*Обводка окружности:*

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Green;
    paint.Style = SKPaintStyle.Stroke;
    paint.StrokeWidth = 4;
    paint.IsAntialias = true;
    canvas.DrawCircle(100, 100, 40, paint);
}
```

*Эллипс:* 

```cs
var rect = SKRect.Create(10, 10, 80, 60);
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Blue;
    paint.Style = SKPaintStyle.Fill;
    canvas.DrawOval(rect, paint);
}
```

*Прямоугольник:*

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Yellow;
    paint.Style = SKPaintStyle.Fill;
    canvas.DrawRect(50, 50, 100, 100, paint); //x,y,ширина,высота,кисть
}
```

*Прямоугольник со скругленными углами:*

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Cyan;
    paint.Style = SKPaintStyle.Stroke;
    paint.StrokeWidth = 2;
    canvas.DrawRoundRect(50, 50, 100, 100, 10, 10, paint);
}
```

*Линия:*

```cs
using(SKPaint paint = new SKPaint())
{
    paint.Color = SKColors.Violet;
    paint.StrokeWidth = 5;
    paint.IsAntialias = true;
    canvas.DrawLine(10, 20, 200, 20, paint);
}
```

=== Работа с цветом и кистью

*Кисть со случайным цветом:*

```cs
var random = new Random();
using (var paint = new SKPaint())
{
    paint.Color = new SKColor(
        (byte)random.Next(0, 256),  // красный
        (byte)random.Next(0, 256),  // зеленый
        (byte)random.Next(0, 256),  // голубой
        (byte)random.Next(128, 256) // прозрачность (немного прозрачный)
    );
    paint.Style = SKPaintStyle.Fill;
    paint.IsAntialias = true;
    canvas.DrawCircle(100, 100, 40, paint);
}
```

Также можно использовать `SKColors` --- набор предопределённых цветов, и `SKColor` --- структуру `RGBA`, если нужен точный контроль над компонентами цвета и прозрачностью.

=== Текст и шрифты

```cs
using (SKPaint textPaint = new SKPaint())
{
  textPaint.Color = SKColors.White;
  textPaint.Style = SKPaintStyle.Fill;
  textPaint.IsAntialias = true; //сглаживание

  using var font = new SKFont
  {
    Size = 24,
    Typeface = SKTypeface.FromFamilyName("Arial")
  };

  canvas.DrawText("Hello, World!", 
    new SKPoint(200, 200), 
    SKTextAlign.Left,
    font,
    textPaint);
}
```

Чтобы, например, нарисовать текст по центру холста, можно сначала вычислить его размер:

```cs
string text = "Центр";
using var paint = new SKPaint { Color = SKColors.Black, IsAntialias = true };
using var font = new SKFont { Size = 32, Typeface = SKTypeface.FromFamilyName("Arial") };

var bounds = new SKRect();
paint.MeasureText(text, ref bounds);

float x = (canvas.LocalClipBounds.Width - bounds.Width) / 2 - bounds.Left;
float y = (canvas.LocalClipBounds.Height - bounds.Height) / 2 - bounds.Top;

canvas.DrawText(text, x, y, font, paint);
```

=== Трансформации: перенос, масштаб, поворот.

`SKCanvas` позволяет менять систему координат, а не пересчитывать вручную все точки.

*Перенос (Translate):*

```cs
canvas.Save();            // сохраняем состояние
canvas.Translate(100, 50); // смещаем систему координат

using var paint = new SKPaint
{
    Color = SKColors.Orange,
    Style = SKPaintStyle.Fill
};

canvas.DrawRect(0, 0, 50, 50, paint); // фактически рисуется в (100,50)
canvas.Restore();          // восстанавливаем состояние
```

*Масштабирование (Scale):*
```cs
canvas.Save();
canvas.Scale(2, 2);  // всё будет в 2 раза больше

using var paint = new SKPaint { Color = SKColors.DarkBlue, Style = SKPaintStyle.Stroke, StrokeWidth = 2 };
canvas.DrawCircle(50, 50, 30, paint); // визуально радиус будет 60

canvas.Restore();
```

*Поворот (RotateDegrees):*

```cs
canvas.Save();
canvas.Translate(150, 150);   // перенос в центр будущего квадрата
canvas.RotateDegrees(45);     // поворот системы координат

using var paint = new SKPaint { Color = SKColors.Brown, Style = SKPaintStyle.Fill };
canvas.DrawRect(-25, -25, 50, 50, paint); // квадрат 50x50 с центром в (0,0)

canvas.Restore();
```

=== Сложные пути: `SKPath`

`SKPath` позволяет создавать *сложные фигуры из отрезков и кривых*.

```cs
var path = new SKPath();
path.MoveTo(50, 50);
path.LineTo(150, 50);
path.LineTo(150, 150);
path.LineTo(50, 150);
path.Close(); // замыкаем путь, соединяя последнюю и первую точки

using var paint = new SKPaint
{
    Color = SKColors.DarkGreen,
    Style = SKPaintStyle.StrokeAndFill,
    StrokeWidth = 3,
    IsAntialias = true
};

canvas.DrawPath(path, paint);
```

Можно добавлять *дуги и кривые Безье:*

```cs
var curve = new SKPath();
curve.MoveTo(20, 200);
curve.CubicTo(80, 100, 160, 300, 220, 200); // кубическая кривая

using var curvePaint = new SKPaint
{
    Color = SKColors.Magenta,
    Style = SKPaintStyle.Stroke,
    StrokeWidth = 4,
    IsAntialias = true
};

canvas.DrawPath(curve, curvePaint);
```

=== Эффекты линий: пунктир и скругления

*Пунктирная линия:*

```cs
using var paint = new SKPaint
{
    Color = SKColors.Black,
    Style = SKPaintStyle.Stroke,
    StrokeWidth = 3,
    IsAntialias = true,
    PathEffect = SKPathEffect.CreateDash(new float[] { 10, 5 }, 0)
};

canvas.DrawLine(10, 250, 300, 250, paint);
```

*Форма конца линии (`StrokeCap`):*

```cs
using var capPaint = new SKPaint
{
    Color = SKColors.Red,
    Style = SKPaintStyle.Stroke,
    StrokeWidth = 15,
    IsAntialias = true,
    StrokeCap = SKStrokeCap.Round // круглые концы линий
};

canvas.DrawLine(50, 300, 250, 300, capPaint);
```


== Выполнение индивидуального задания

Создайте собственное приложение выводящее рисунок, состоящий из различных объектов (линий, многоугольников, эллипсов, прямоугольников и пр.), не закрашенных и закрашенных полностью. Используйте разные цвета и стили линий (сплошные, штриховые, штрих-пунктирные).


= Часть 2. Обработка изображений в Avalonia с SkiaSharp

== Отображение графических файлов

В Avalonia для создания графического редактора используется связка из нескольких компонентов, каждый из которых выполняет свою уникальную функцию в процессе отрисовки и отображении на экран. Основным визуальным элементом выступает `Canvas`, а результат рисования накладывается на него как фон через специальную кисть.
Ключевые компоненты:
- `SKBitmap` --- это основной объект в оперативной памяти, на котором происходит всё рисование;
- `SKCanvas` --- объект-инструмент, который предоставляет методы для рисования (линии, круги, прямоугольники) поверх `SKBitmap`;
- `WriteableBitmap` --- специальный вид изображения в Avalonia, созданный для динамического изменения;
- `ImageBrush` --- отображение `WriteableBitmap` на `Canvas`.

== Диалоги выбора файлов в Avalonia

`StorageProvider` --- диалоговое окно для файловой системы.

*Открытие файла:*
```cs
var files = await StorageProvider.OpenFilePickerAsync(new FilePickerOpenOptions 
{ 
    Title = "Выберите изображение",
    FileTypeFilter = new[] 
    { 
        new FilePickerFileType("Изображения", new[] { "png", "jpg", "jpeg", "bmp", "gif", "webp" })
    }
});

if (files.Count > 0)
{
    var stream = await files.OpenReadAsync();
    image.Source = new Bitmap(stream);
}
```

*Сохранение файла:*

```cs
var file = await StorageProvider.SaveFilePickerAsync(new FilePickerSaveOptions 
{ 
    Title = "Сохранить как...",
    SuggestedFileName = "result.png",
    FileTypeChoices = new[] 
    { 
        new FilePickerFileType("PNG", new[] { "png" }),
        new FilePickerFileType("JPEG", new[] { "jpg" })
    }
});

if (file != null)
{
    using var stream = await file.OpenWriteAsync();
    // сохранение...
}
```

== Простой графический редактор

*Задача:*

Создать приложение с функциями:
- открытия изображения;
- рисования поверх кистью мышью;
- сохранения обработанного изображения.

*Решение:*

XAML:

```xaml
 <Grid RowDefinitions="Auto,*" ColumnDefinitions="*,Auto">
        <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="10">
            <Button Name="OpenButton" Content="Открыть" Click="OpenImage_Click" Margin="5"/>
            <Button Name="SaveButton" Content="Сохранить" Click="SaveImage_Click" Margin="5"/>
            <Button Name="GrayscaleButton" Content="Ч/Б" Click="Grayscale_Click" Margin="5"/>
        </StackPanel>
        
        <ScrollViewer Grid.Row="1" Margin="10" 
                      HorizontalScrollBarVisibility="Auto"
                      VerticalScrollBarVisibility="Auto"
                      MinWidth="700" MinHeight="500">
            <Border BorderBrush="Gray" BorderThickness="1" Background="White">
                <Canvas Name="ImageCanvas" Background="White" 
                        PointerPressed="OnMouseDown" 
                        PointerMoved="OnMouseMove"/>
            </Border>
        </ScrollViewer>
    </Grid>
```

Основной код редактора:
```cs
public partial class MainWindow : Window
{
    private Point? previousPoint;      //последняя точка мыши для рисования линии
    private SKBitmap? skBitmap;        //основное изображение
    private SKCanvas? skCanvas;        //холст для рисования поверх изображения
    private SKPaint paint;             //настройки кисти
    private WriteableBitmap? avaloniaBitmap; //копия для отображения в Avalonia UI

    public MainWindow()
    {
        InitializeComponent();
        paint = new SKPaint //стиль кисти
        {
            Color = SKColors.Black,
            StrokeWidth = 4,
            IsAntialias = true
        };
    }

    private async void OpenImage_Click(object sender, Avalonia.Interactivity.RoutedEventArgs e)
    {
        var files = await StorageProvider.OpenFilePickerAsync(new FilePickerOpenOptions //кросс-платформенное диалоговое окно
        {
            Title = "Открыть изображение",
            AllowMultiple = false,
            FileTypeFilter = new[]
            {
                new FilePickerFileType("Изображения")
                {
                    Patterns = new[] { "*.bmp", "*.jpg", "*.jpeg", "*.png", "*.gif", "*.tiff", "*.ico" }
                }
            }
        });
        if (files.Count > 0)
        {
            //декодирование в SkiaSharp
            using var stream = await files[0].OpenReadAsync();
            skBitmap = SKBitmap.Decode(stream);
            
            if (skBitmap != null)
            {
                avaloniaBitmap = new WriteableBitmap(
                    new PixelSize(skBitmap.Width, skBitmap.Height),
                    new Vector(96, 96),
                    Avalonia.Platform.PixelFormat.Bgra8888,
                    AlphaFormat.Premul);
                UpdateCanvasImage();
                skCanvas = new SKCanvas(skBitmap);
                ImageCanvas.Width = skBitmap.Width;
                ImageCanvas.Height = skBitmap.Height;
            }
        }
    }
    private async void SaveImage_Click(object sender, Avalonia.Interactivity.RoutedEventArgs e)
    {
        if (skBitmap == null) return;
        var file = await StorageProvider.SaveFilePickerAsync(new FilePickerSaveOptions
        {
            Title = "Сохранить как...",
            DefaultExtension = ".png",
            FileTypeChoices = new[]
            {
                new FilePickerFileType("PNG") { Patterns = new[] { "*.png" } },
                new FilePickerFileType("JPEG") { Patterns = new[] { "*.jpg" } },
                new FilePickerFileType("BMP") { Patterns = new[] { "*.bmp" } },
                new FilePickerFileType("GIF") { Patterns = new[] { "*.gif" } }
            }
        });
        if (file != null)
        {
            using var stream = await file.OpenWriteAsync();
            var format = Path.GetExtension(file.Path.LocalPath).ToLower() switch
            {
                ".png" => SKEncodedImageFormat.Png,
                ".jpg" or ".jpeg" => SKEncodedImageFormat.Jpeg,
                ".bmp" => SKEncodedImageFormat.Bmp,
                ".gif" => SKEncodedImageFormat.Gif,
                _ => SKEncodedImageFormat.Png
            };
            skBitmap.Encode(stream, format, 100);
        }
    }
    private void Grayscale_Click(object sender, Avalonia.Interactivity.RoutedEventArgs e)
    {
        if (skBitmap == null) return;
        for (int x = 0; x < skBitmap.Width; x++)
        for (int y = 0; y < skBitmap.Height; y++)
        {
            var pixel = skBitmap.GetPixel(x, y);
            var gray = (byte)(0.299 * pixel.Red + 0.587 * pixel.Green + 0.114 * pixel.Blue);
            skBitmap.SetPixel(x, y, new SKColor(gray, gray, gray));
        }
        UpdateCanvasImage();
    }
    private void OnMouseDown(object sender, PointerPressedEventArgs e)
    {
        var position = e.GetPosition(ImageCanvas);
        previousPoint = new Point((float)position.X, (float)position.Y);
    }
    private void OnMouseMove(object sender, PointerEventArgs e)
    {
        if (skCanvas == null || previousPoint == null) return;
        var pointerPoint = e.GetCurrentPoint(ImageCanvas);
        if (!pointerPoint.Properties.IsLeftButtonPressed) return;
        var position = e.GetPosition(ImageCanvas);
        var point = new Point((float)position.X, (float)position.Y);
        skCanvas.DrawLine(
            new SKPoint((float)previousPoint.Value.X, (float)previousPoint.Value.Y),
            new SKPoint((float)point.X, (float)point.Y), 
            paint);

        previousPoint = point;
        UpdateCanvasImage();
    }

    private void UpdateCanvasImage()
    {
        if (skBitmap == null || avaloniaBitmap == null) return;
        using var locked = avaloniaBitmap.Lock();
        using var surface = SKSurface.Create(new SKImageInfo(skBitmap.Width, skBitmap.Height, SKColorType.Bgra8888));
        surface.Canvas.DrawBitmap(skBitmap, 0, 0);
        surface.Snapshot().ReadPixels(
            new SKImageInfo(skBitmap.Width, skBitmap.Height, SKColorType.Bgra8888), 
            locked.Address, 
            locked.RowBytes);
        Dispatcher.UIThread.Post(() =>
        {
            var imageBrush = new ImageBrush(avaloniaBitmap) { Stretch = Stretch.None };
            ImageCanvas.Background = imageBrush;
        });
    }
}
```

== Выполнение индивидуального задания

+ Расширьте приложение путем добавления возможности выбора пользователем цвета и величины кисти.

+ Разработайте функцию, оставляющую на изображении только один из каналов (R, G, B). Канал выбирается пользователем.

+ Создайте функцию, отрисовывающую окружность. Центр окружности совпадает с центром изображения. Все точки вне окружности закрашиваются черным цветом. Все точки внутри окружности остаются неизменными. Радиус окружности задается пользователем.

+ Создайте функцию, выводящую на изображение треугольник. Все точки вне треугольника закрашиваются синим цветом. Все точки внутри треугольника остаются неизменными. 

+ Создайте функцию, выводящую на изображение ромб. Все точки вне ромба переводятся в градации серого цвета. Все точки внутри ромба закрашиваются зеленым цветом. 

+ Создайте функцию, разбивающую изображение на три равные части. В каждой оставьте значение только одного канала R, G и B.

+ Разработайте функцию, заменяющую все точки синего цвета на точки красного цвета. 

+ Создайте функцию, инвертирующую  изображение в градациях серого цвета в негатив.

+ Создайте функцию, инвертирующую  изображение в негатив.

+ Создайте функцию, изменяющую яркость изображения путем прибавления или уменьшения заданной пользователем величины к каждому каналу.

+ Создайте функцию, переводящую изображение в черно-белый формат в соответствии с пороговым значением, которое ввел пользователь.
