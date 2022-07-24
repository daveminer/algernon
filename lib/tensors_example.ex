defmodule TensorsExample do
  @moduledoc """
  """
  require Axon

  defp build_model(input_shape1, input_shape2, input_shape3, input_shape4) do
    inp1 = Axon.input(input_shape1, "open")
    inp2 = Axon.input(input_shape2, "close")
    inp3 = Axon.input(input_shape3, "high")
    inp4 = Axon.input(input_shape4, "low")

    inp1
    |> Axon.concatenate(inp2)
    |> Axon.concatenate(inp3)
    |> Axon.concatenate(inp4)
    |> Axon.dense(8, activation: :tanh)
    |> Axon.dense(1, activation: :sigmoid)
  end

  # create sample data to be streamed into the model
  defp batch do
    open = stream_and_decode()
      |> Enum.map(fn {_, %{"Open" => open}} -> [String.to_float(open)] end)
      |> Enum.to_list()
      |> Nx.tensor()
    close = stream_and_decode()
      |> Enum.map(fn {_, %{"Close" => close}} -> [String.to_float(close)] end)
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

    # time series normalization equation: (x - min) / (max - min)
    # https://tcoil.info/normalize-stock-prices-and-time-series-data-with-python-2/
    # x - price from input time series
    # min - minimum price in the time seies
    # max - maximum price of the time series
    target = stream_and_decode()
      |> Enum.map(fn {_, %{"Close" => close, "Low" => low, "High" => high}} ->
        x = String.to_float(close)
        min = String.to_float(low)
        max = String.to_float(high)
        [(x - min) / (max - min)]
      end)
      |> Nx.tensor()

    # target = stream_and_decode()
    #   |> Enum.map(fn {_, %{"Close" => close}} -> [String.to_float(close)] end)
    #   |> Nx.tensor()

    # {%{"open" => open, "high" => high, "low" => low}, target}

    {%{"open" => open, "high" => high, "low" => low, "close" => close}, target}
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
    model = build_model({nil, 1}, {nil, 1}, {nil, 1}, {nil, 1})
    data = Stream.repeatedly(&batch/0)

    # As the data comes in here, it matches the model.
    model_state = train_model(model, data, 2)

    IO.inspect(
      Axon.predict(model, model_state, %{
        "open" => Nx.tensor([[0]]),
        "close" => Nx.tensor([[1]]),
        "high" => Nx.tensor([[2]]),
        "low" => Nx.tensor([[3]])
      })
    )
  end
end
