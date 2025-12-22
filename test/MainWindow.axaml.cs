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

    private void OnCalculateClick(object? sender, RoutedEventArgs e)
    {
        textBox5.Text = "";

        try
        {
            // Считывание исходных данных
            double x0 = Convert.ToDouble(textBox1.Text);
            double xk = Convert.ToDouble(textBox2.Text);
            double dx = Convert.ToDouble(textBox3.Text);
            double a = Convert.ToDouble(textBox4.Text);

            // Заголовок
            textBox5.Text =
                "Работу выполнил Иванов И.И. 251 гр." + Environment.NewLine;

            // Табулирование функции
            double x = x0;
            while (x <= xk + dx / 2)
            {
                double y = a * Math.Log(x);

                // Округление до 3 знаков после запятой
                double xRounded = Math.Round(x, 3);

                textBox5.Text +=
                    "x=" + xRounded.ToString() +
                    "; y=" + y.ToString() +
                    Environment.NewLine;

                x = x + dx;
            }
        }
        catch (FormatException)
        {
            textBox5.Text =
                "Ошибка: введите корректные числовые данные.";
        }
        catch (Exception ex)
        {
            textBox5.Text =
                "Ошибка выполнения: " + ex.Message;
        }
    }
}
