import 'package:equatable/equatable.dart';

class BaseState<T> extends Equatable {
  final bool isLoading;
  final String? error;
  final T? data;

  const BaseState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  BaseState<T> copyWith({
    bool? isLoading,
    String? error,
    T? data,
  }) {
    return BaseState<T>(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, data];
}