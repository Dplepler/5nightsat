extends Node

static func _create_promise(promise_sig : Signal):
	return Promise.new(
		func(resolve: Callable, reject: Callable):
		await promise_sig
		resolve.call()
	)
