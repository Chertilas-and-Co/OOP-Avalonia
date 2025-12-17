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

Аналог PaintEventArgs в SkiaSharp --- это SKPaint, который содержит информацию о стиле, цвете и способе отрисовки геометрических фигур, текста и растровых изображений. SKPaint по сути представляет собой кисть.

Пример использования SKPaint

```csharp
using(SKPaint paint = new SKPaint())
{
    //задание цвета с помощью структуры SKColors
    paint.Color = SKColors.Violet;
    
    //задание толщины кисти для обводки
    paint.StrokeWidth = 15;
    
    //Style используется как задания так и для получения стиля
    //SKPaintStyle.Stroke - только обводка
    //SKPaintStyle.Fill - только заливка
    //SKPaintStyle.StrokeAndFill - обводка и заливка
    paint.Style = SKPaintStyle.Stroke;
}
```

== Объект для рисования

Вместо Graphics в GDI, в Avalonia, с подключением SkiaSharp используется SKCanvas. SKCanvas представляет собой поверхность для отрисовки фигур, линий, изображений, текста и т.д.

Отличие состоит в том, что объект Graphics создать напрямую нельзя, хотя и существует несколько способов получения его экземпляра. 


Пример использования SKBitmap

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

Рисование также осуществляется слоями, которые перкрывают друг друга.

В Windows Forms используется PictureBox для отображения Bitmap. В Avalonia для аналогичных целей используется Image контрол, но его нельзя напрямую присвоить SKBitmap, поэтому требуется конвертирование SKBitmap в Avalonia Bitmap.

Вот как может выглядеть код на axaml

```xaml
<Image x:Name="imageTest" Width="500" Height="500"/> 
```

== Способы рисования

Класс SKCanvas содержит методы для рисования различных фигур. На месте методов DrawEllipse, FillEllipse из GDI+ используются DrawCircle, DrawOval, DrawRect и другие.

Всем методам можно задать стиль с помощью SKPaint. У фигур можно отрисовывать как только обводку, так и заливать полностью.

Примеры отрисовки фигур.

Заполненная окружность

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Red;
    paint.Style = SKPaintStyle.Fill;
    canvas.DrawCircle(50, 50, 30, paint);
}
```
Обводка окружности

```cs
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Green;
    paint.Style = SKPaintStyle.Stroke;
    paint.StrokeWidth = 4;
    canvas.DrawCircle(100, 100, 40, paint);
}
```

Эллипс

```csharp
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

```csharp
using (var paint = new SKPaint())
{
    paint.Color = SKColors.Cyan;
    paint.Style = SKPaintStyle.Stroke;
    paint.StrokeWidth = 2;
    canvas.DrawRoundRect(50, 50, 100, 100, 10, 10, paint);//первые 10 здесь радиус скругления по x, а вторые по y
}
```

Линия

```cs
using(SKPaint paint = new SKPaint())
{
    paint.Color = SKColors.Violet;
    paint.StrokeWidth = 5;
    canvas.DrawLine(10, 20, 200, 20, paint);
}
```

Кисть со случайным цветом

```cs
var random = new Random();
using (var paint = new SKPaint())
{
    paint.Color = new SKColor(
        (byte)random.Next(0, 256),//красный
        (byte)random.Next(0, 256),//зеленый
        (byte)random.Next(0, 256),//голубой
        (byte)random.Next(0, 256)//прозрачность
    );
    paint.Style = SKPaintStyle.Fill;
    canvas.DrawCircle(100, 100, 40, paint);
}
```

Текст

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

Пример отрисовки по нажатию на кнопку

```xaml
<Button x:Name="ButtonTest"
        Content="Сгенерировать изображение"
        Click="Button_Click" /> 
```

```cs
private void Button_Click(object sender, Avalonia.Interactivity.RoutedEventArgs e)
{
  var button = sender as Button;
  if (button != null)
  {
      button.Content = "Изображение сгенерировано!";
  
  SKImageInfo imageInfo = new SKImageInfo(500,500);
  using (var skBitmap = new SKBitmap(imageInfo))
  using (var canvas = new SKCanvas(skBitmap))
  {
    //ваш код
  }
  //конвертирование SKBitmap в Avalonia Bitmap
}
```

== Методы, свойства и классы SkiaSharp



== Выполнение индивидуального задания


= Часть 2. Обработка изображений