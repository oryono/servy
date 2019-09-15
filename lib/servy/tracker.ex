defmodule Servy.Tracker do
  def get_location(car_name) do
    :timer.sleep(500)

    cars = %{
      "bmw" => %{lat: "32.3456 N", lng: "101.234 W"},
      "toyota" => %{lat: "31.3456 N", lng: "11.234 W"},
      "volkwagen" => %{lat: "22.3456 N", lng: "91.234 W"},
      "audi" => %{lat: "42.3456 N", lng: "75.234 W"}
    }

    Map.get(cars, car_name)
  end
end
