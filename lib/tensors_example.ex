defmodule TensorsExample do
  @moduledoc """
  """
  require Axon

  defp build_model(input_shape1, input_shape2, input_shape3) do
    inp1 = Axon.input(input_shape1, "open")
    inp2 = Axon.input(input_shape2, "high")
    inp3 = Axon.input(input_shape3, "low")

    inp1
    |> Axon.concatenate(inp2)
    |> Axon.concatenate(inp3)
    |> Axon.dense(8, activation: :tanh)
    |> Axon.dense(1, activation: :sigmoid)
  end

  # create sample data to be streamed into the model
  defp batch do
    open = stream_and_decode()
      |> Enum.map(fn {_, %{"Open" => open}} -> [String.to_float(open)] end)
      |> Enum.to_list()
      |> Nx.tensor()
    high = stream_and_decode()
      |> Enum.map(fn {_, %{"High" => high}} -> [String.to_float(high)] end)
      |> Enum.to_list()
      |> Nx.tensor()
    low = stream_and_decode()
      |> Enum.map(fn {_, %{"Low" => low}} -> [String.to_float(low)] end)
      |> Enum.to_list()
      |> Nx.tensor()

    targets = stream_and_decode()
      |> Enum.map(fn {_, %{"Close" => close}} -> [String.to_float(close)] end)
      |> Nx.tensor()

    {%{"open" => open, "high" => high, "low" => low}, targets}
  end

  defp stream_and_decode() do
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
    # nil means the value will be provided later (done on the next line)
    model = build_model({nil, 1}, {nil, 1}, {nil, 1})
    data = Stream.repeatedly(&batch/0)

    # As the data comes in here, it matches the model.
    model_state = train_model(model, data, 2)

    IO.inspect(
      Axon.predict(model, model_state, %{
        "open" => Nx.tensor([[0]]),
        "high" => Nx.tensor([[1]]),
        "low" => Nx.tensor([[2]])
      })
    )
  end
end
