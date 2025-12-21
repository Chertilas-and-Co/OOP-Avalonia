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

Установка nuget-пакетов

- Avalonia.Skia (dotnet add package Avalonia.Skia --version 11.3.9) Осторожно! Так как может быть конфликт с версией самой Avalonia
- SkiaSharp (dotnet add package SkiaSharp --version 3.119.1) Непосредственно библиотека, с которой будем работать
- SkiaSharp.NativeAssets.Linux (dotnet add package SkiaSharp.NativeAssets.Linux) То, что уникально для каждой платформы

Проверка, что оно добавилось в проект

В файле .csproj должны быть следующее:

```xaml
    <PackageReference Include="SkiaSharp" Version="3.119.1" />
    <PackageReference Include="SkiaSharp.NativeAssets.Linux" Version="3.119.1" />
    <PackageReference Include="Avalonia.Skia" Version="11.3.6"/>
```


= Часть 1. Программирование графики

== WM_PAINT и ..

В классическом Windows через WM_PAINT операционная система уведомляет приложение о необходимости перерисовать окно. Это происходит при перемещении, изменении размера или открытии окна.

В Avalonia нет прямого аналога WM_PAINT.

== SKPaint


В System.Windows.Forms существует событие Paint, которое триггерится при необходимости перерисовки. В Avalonia, с использованием SkiaSharp это событие заменяется Render методом кастомного контрола или RenderSkia событием для специализированных компонентов.

Аналог PaintEventArgs в SkiaSharp --- это SKPaint. Он содержит полный набор параметров для отрисовки:
- Цвет (RGBA)
- Стиль заливки/обводки
- Толщина линий
- Сглаживание
- Эффекты пути (пунктир)
- Параметры шрифта

Пример использования SKPaint

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
    paint.Style = SKPaintStyle.Stroke;           // только обводка
    // paint.Style = SKPaintStyle.Fill;           // только заливка
    // paint.Style = SKPaintStyle.StrokeAndFill;  // обводка + заливка

    // 6. Форма концов линий
    paint.StrokeCap = SKStrokeCap.Round;

    // 7. Соединение линий
    paint.StrokeJoin = SKStrokeJoin.Round;

    // 8. Пунктирный эффект
    paint.PathEffect = SKPathEffect.CreateDash(new[] {10f, 5f}, 0);
}
```

== Объект для рисования

Вместо Graphics в GDI (Graphics Device Interface -- является интерфейсом Windows, предназначенным для представления графических объектов. Объект Graphics представляет поверхность рисования GDI и используется для создания графических изображений) в Avalonia, с подключением SkiaSharp, используется SKCanvas. SKCanvas представляет собой поверхность для отрисовки фигур, линий, изображений, текста и т.д.

Отличие состоит в том, что объект Graphics создать напрямую нельзя, хотя и существует несколько способов получения его экземпляра, а SKCanvas можно. 


Пример использования SKCanvas

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
Здесь же появляется SKBitmap. Он используется как изменяемая растровая поверхность для рисования в памяти. Фактически представляет собой массив пикселей в памяти (как холст на мольберте)

Почему используется цепочка конвертирования: SKImage.FromBitmap() $arrow.r$ Encode() $arrow.r$ MemoryStream $arrow.r$ Bitmap()?

Эта цепочка необходима потому, что SKBitmap и Avalonia Bitmap --- это разные типы, находящиеся в разных библиотеках с разными внутренними представлениями данных.

- SKImage.FromBitmap(skBitmap) создаёт неизменяемый образ из SKBitmap. 
- image.Encode(SKEncodedImageFormat.Png, 100) кодирует SKImage в стандартный формат PNG с качеством 100%. (можно выбрать другой формат изображения).
- data.ToArray() преобразует SKData в массив байтов (byte[]). Это необходимо для взаимодействия с MemoryStream, а bytes --- это самый базовый формат, поддерживаемый всеми платформами.
- new MemoryStream(byte[]) оборачивает массив байтов в поток в памяти.
- new Bitmap(memoryStream). Конструктор Bitmap принимает Stream, который он использует для загрузки изображения.

Также можно отрисовывать напрямую с помощью Bitmap.

Пример использования Bitmap

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

В Windows Forms используется PictureBox для отображения Bitmap. В Avalonia для аналогичных целей используется Image контрол, но его нельзя напрямую присвоить SKBitmap, поэтому требуется конвертирование SKBitmap в Avalonia Bitmap.

Вот как может выглядеть код на axaml

```xaml
<Image x:Name="imageTest" Width="500" Height="500"/> 
```

== Методы, свойства и классы SkiaSharp

Класс SKCanvas содержит методы для рисования различных фигур. На месте методов DrawEllipse, FillEllipse из GDI+ используются DrawCircle, DrawOval, DrawRect и другие.

Всем методам можно задать стиль с помощью SKPaint. У фигур можно отрисовывать как только обводку, так и заливать полностью.

=== Базовые примитивы SKCanvas

Заполненная окружность (в научных кругах --- круг)

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Red;
    paint.Style = SKPaintStyle.Fill;
    paint.IsAntialias = true; // сглаживание краёв
    canvas.DrawCircle(50, 50, 30, paint);
}
```

Обводка окружности (в научных кругах --- окружность)

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

Эллипс (ну тут все правильно)

```cs
var rect = SKRect.Create(10, 10, 80, 60);
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Blue;
    paint.Style = SKPaintStyle.Fill;
    canvas.DrawOval(rect, paint);
}
```

Прямоугольник 

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Yellow;
    paint.Style = SKPaintStyle.Fill;
    canvas.DrawRect(50, 50, 100, 100, paint); //x,y,ширина,высота,кисть
}
```

Прямоугольник со скругленными углами

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Cyan;
    paint.Style = SKPaintStyle.Stroke;
    paint.StrokeWidth = 2;
    canvas.DrawRoundRect(50, 50, 100, 100, 10, 10, paint);
}
```

Линия

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

Кисть со случайным цветом

```cs
var random = new Random();
using (var paint = new SKPaint())
{
    paint.Color = new SKColor(
        (byte)random.Next(0, 256),//красный
        (byte)random.Next(0, 256),//зеленый
        (byte)random.Next(0, 256),//голубой
        (byte)random.Next(128, 256)//прозрачность (немного прозрачный)
    );
    paint.Style = SKPaintStyle.Fill;
    paint.IsAntialias = true;
    canvas.DrawCircle(100, 100, 40, paint);
}
```

Также можно использовать SKColors — набор предопределённых цветов, и SKColor — структуру RGBA, если нужен точный контроль над компонентами цвета и прозрачностью.

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

Чтобы, например, нарисовать текст по центру холста, можно сначала измерить его размер:

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

=== Трансформации: перенос, масштаб, поворот

SKCanvas позволяет менять систему координат, а не пересчитывать вручную все точки.

Перенос (Translate):

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

Масштабирование (Scale):

```cs
canvas.Save();
canvas.Scale(2, 2);  // всё будет в 2 раза больше

using var paint = new SKPaint { Color = SKColors.DarkBlue, Style = SKPaintStyle.Stroke, StrokeWidth = 2 };
canvas.DrawCircle(50, 50, 30, paint); // визуально радиус будет 60

canvas.Restore();
```

Поворот (RotateDegrees):

```cs
canvas.Save();
canvas.Translate(150, 150);   // перенос в центр будущего квадрата
canvas.RotateDegrees(45);     // поворот системы координат

using var paint = new SKPaint { Color = SKColors.Brown, Style = SKPaintStyle.Fill };
canvas.DrawRect(-25, -25, 50, 50, paint); // квадрат 50x50 вокруг (0,0)

canvas.Restore();
```

=== Сложные пути: SKPath

SKPath позволяет создавать сложные фигуры из отрезков и кривых.

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

Можно добавлять дуги и кривые Безье:

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

Пунктирная линия:

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

Форма конца линии (StrokeCap):

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


= Часть 2. Обработка изображений