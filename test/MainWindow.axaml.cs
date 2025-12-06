using Avalonia.Controls;
using Avalonia.Interactivity;
using System;

namespace test;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
    }

    // Обработка кнопки "ПУСК"
    private void OnRunClick(object? sender, RoutedEventArgs e)
    {
        textBox4.Text = ""; // Очистка перед выводом нового результата

        try
        {
            // Получение исходных данных
            double x = double.Parse(textBox1.Text!);
            double y = double.Parse(textBox2.Text!);
            double z = double.Parse(textBox3.Text!);

            // Вывод исходных данных
            textBox4.Text =
                "Результаты работы программы Петрова И.И." + Environment.NewLine +
                "При X = " + x + Environment.NewLine +
                "При Y = " + y + Environment.NewLine +
                "При Z = " + z + Environment.NewLine;

            // Определение выбранной функции f(x)
            int n = 0;
            if (rbCos.IsChecked == true)
            {
                n = 1;
            }
            else if (rbExp.IsChecked == true)
            {
                n = 2;
            }

            // Выбор функции f(x)
            double fx;

            switch (n)
            {
                case 0:
                    fx = Math.Sin(x);
                    break;

                case 1:
                    fx = Math.Cos(x);
                    break;

                case 2:
                    fx = Math.Exp(x);
                    break;

                default:
                    fx = 0;
                    break;
            }

            // Вычисление U
            double u;
            double diff = z - x;

            if (diff == 0)
            {
                u = y * fx * fx + z;
            }
            else if (diff < 0)
            {
                u = y * Math.Exp(fx) - z;
            }
            else
            {
                u = y * Math.Sin(fx) + z;
            }

            // Вывод результата
            textBox4.Text += "U = " + u.ToString() + Environment.NewLine;
        }
        catch (FormatException)
        {
            textBox4.Text += Environment.NewLine +
                "Ошибка: введены некорректные данные.";
        }
        catch (Exception ex)
        {
            textBox4.Text += Environment.NewLine +
                "Неизвестная ошибка: " + ex.Message;
        }
    }

    // Обработка кнопки "Очистить"
    private void OnClearClick(object? sender, RoutedEventArgs e)
    {
        textBox1.Text = "";
        textBox2.Text = "";
        textBox3.Text = "";
        textBox4.Text = "";
    }
}
