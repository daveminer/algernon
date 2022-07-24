build:
	docker build -t ml_demo .
demo:
	docker run ml_demo; iex -S mix
