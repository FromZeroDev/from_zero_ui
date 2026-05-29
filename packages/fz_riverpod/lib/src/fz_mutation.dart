import 'dart:async';

import 'package:riverpod/experimental/mutation.dart';

abstract class FzMutationBase<R> {
  final Mutation<R> mutation;

  FzMutationBase([Mutation<R>? mutation]) //
    : mutation = mutation ?? Mutation();

  void reset(MutationTarget container) {
    mutation.reset(container);
  }

  Future<R> run(MutationTarget target);
}

class FzMutation<R> extends FzMutationBase<R> {
  final Future<R> Function(MutationTransaction txn) executor;

  FzMutation(this.executor);

  @override
  Future<R> run(MutationTarget target) {
    return mutation.run(target, executor);
  }
}

abstract class FzMutationFamilyBase<T, R> {
  final mutation = Mutation<R>();

  FzMutationInstance<T, R> call(T data) {
    return FzMutationInstance<T, R>._(
      mutation: mutation.call(getId(data)),
      data: data,
      executor: execute,
    );
  }

  Future<R> execute(MutationTransaction txn, T data);

  Object? getId(T data) => data;
}

class FzMutationFamily<T, R> extends FzMutationFamilyBase<T, R> {
  final Future<R> Function(MutationTransaction txn, T data) executor;
  Object? Function(T data)? idGetter;

  FzMutationFamily(
    this.executor, {
    this.idGetter,
  });

  @override
  Future<R> execute(MutationTransaction txn, T data) {
    return executor(txn, data);
  }

  @override
  Object? getId(T data) {
    if (idGetter case final idGetter?) {
      return idGetter(data);
    }
    return super.getId(data);
  }
}

class FzMutationInstance<T, R> extends FzMutationBase<R> {
  final Future<R> Function(MutationTransaction txn, T data) executor;
  final T data;

  FzMutationInstance._({
    required Mutation<R> mutation,
    required this.data,
    required this.executor,
  }) : super(mutation);

  @override
  Future<R> run(MutationTarget target) {
    return mutation.run(target, (txn) => executor(txn, data));
  }
}
