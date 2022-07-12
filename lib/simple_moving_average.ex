defmodule SimpleMovingAverage do
  @moduledoc """
  Documentation for `Algernon`.
  """

  require Axon

  defp build_model(input_shape1),
    do:
      Axon.input(input_shape1, "close")
      |> Axon.dense(8, activation: :tanh)
      |> Axon.dense(1, activation: :sigmoid)

  defp batch do
    "data/FUND_US_ARCX_SPY.csv"
    |> File.stream!()
    |> CSV.decode(separator: ?,, headers: true)
  end

  defp train_model(model, data, epochs) do
    model
    |> Axon.Loop.trainer(:binary_cross_entropy, :sgd)
    |> Axon.Loop.run(data, %{}, epochs: epochs, iterations: 1000)
  end

  def start do
    model = build_model({nil, 1})

    data =
      Stream.map(batch(), fn item ->
        close = elem(item, 1)["Close"]
        {%{"close" => Float.parse(close) |> elem(0)}, 1}
      end)

    model_state = train_model(model, data, 10)

    IO.inspect("Won't make it here.")

    IO.inspect(Axon.predict(model, model_state, %{"close" => Nx.tensor([[0]])}))
  end
end
