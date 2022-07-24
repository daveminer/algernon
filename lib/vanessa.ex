defmodule Vanessa do
  @moduledoc """
  """
  require Axon

  defp build_model(input_shape1, input_shape2) do
    inp1 = Axon.input(input_shape1, "x1")
    inp2 = Axon.input(input_shape2, "x2")

    inp1
    |> Axon.concatenate(inp2)
    |> Axon.dense(8, activation: :tanh)
    |> Axon.dense(1, activation: :sigmoid)
  end

  # create sample data to be streamed into the model
  defp batch do
    x1 = "data/FUND_US_ARCX_SPY.csv"
      |> File.stream!()
      |> CSV.decode(separator: ?,, headers: true)
      |> Enum.map(fn {_, %{"Open" => open}} -> [String.to_float(open)] end)
      |> Enum.to_list()
      |> Nx.tensor()
    x2 = "data/FUND_US_ARCX_SPY.csv"
      |> File.stream!()
      |> CSV.decode(separator: ?,, headers: true)
      |> Enum.map(fn {_, %{"High" => high}} -> [String.to_float(high)] end)
      |> Enum.to_list()
      |> Nx.tensor()

    targets = "data/FUND_US_ARCX_SPY.csv"
      |> File.stream!()
      |> CSV.decode(separator: ?,, headers: true)
      |> Enum.map(fn {_, %{"Close" => close}} -> [String.to_float(close)] end)
      |> Nx.tensor()

    {%{"x1" => x1, "x2" => x2}, targets}
  end

  defp train_model(model, data, epochs) do
    model
    |> Axon.Loop.trainer(:binary_cross_entropy, :sgd)
    |> Axon.Loop.run(data, %{}, epochs: epochs, iterations: 1000)
  end

  def start do
    # nil means the value will be provided later (done on the next line)
    model = build_model({nil, 1}, {nil, 1})
    data = Stream.repeatedly(&batch/0)

    # As the data comes in here, it matches the model.
    model_state = train_model(model, data, 10)

    IO.inspect(
      Axon.predict(model, model_state, %{"x1" => Nx.tensor([[0]]), "x2" => Nx.tensor([[1]])})
    )
  end
end
