defmodule Algernon do
  @moduledoc """
  Documentation for `Algernon`.
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
    x1 = Nx.tensor(for _ <- 1..32, do: [Enum.random(0..1)])
    x2 = Nx.tensor(for _ <- 1..32, do: [Enum.random(0..1)])
    y = Nx.logical_xor(x1, x2)
    {%{"x1" => x1, "x2" => x2}, y}
  end

  defp train_model(model, data, epochs) do
    model
    |> Axon.Loop.trainer(:binary_cross_entropy, :sgd)
    |> Axon.Loop.run(data, %{}, epochs: epochs, iterations: 1000)
  end

  def start do
    # nil measn the value will be provided later (done on the next line)

    model = build_model({nil, 1}, {nil, 1})
    data = Stream.repeatedly(&batch/0)

    # As the data comes in here, it matches the model. Images are often
    # serialized such that a 32x32 image would be represented as {nil, 1024}.
    # A collection of color images might be modeled like so:
    # {5000, 3, 32, 32}
    # 5000: number of images
    # 3: one for each of RGB format
    # 32: image pixel height
    # 32: image pixel width
    model_state = train_model(model, data, 10)

    IO.inspect(
      Axon.predict(model, model_state, %{"x1" => Nx.tensor([[0]]), "x2" => Nx.tensor([[1]])})
    )
  end
end
