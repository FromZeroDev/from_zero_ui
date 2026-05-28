import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:fz_flutter_riverpod/fz_flutter_riverpod.dart';
import 'package:fz_localizations/fz_localizations.dart';
import 'package:fz_snackbar/fz_snackbar.dart';

abstract class FzDioProviderBuilder {
  static Widget defaultGetErrorIcon(BuildContext context, Object? error, StackTrace? stackTrace) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return const Icon(Icons.do_disturb_on_outlined);
        }
        if (error.response!.statusCode == 404) {
          return const Icon(Icons.error_outline);
        }
        if (error.response!.statusCode! < 500) {
          return const Icon(Icons.do_disturb_on_outlined);
        }
        return const Icon(Icons.report_problem_outlined);
      }
      return const Icon(MaterialCommunityIcons.wifi_off);
    }
    if (error is PartialSuccessError) {
      return Icon(Icons.warning);
    }
    return FzProviderBuilder.defaultGetErrorIcon(context, error, stackTrace);
  }

  static String defaultGetErrorTitle(BuildContext context, Object? error, StackTrace? stackTrace) {
    // TODO: 3 internationalize
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return 'Error de Autorización';
        }
        if (error.response!.statusCode == 404) {
          return 'Recurso no Encontrado';
        }
        if (error.response!.statusCode! < 500) {
          return 'Petición Rechazada por el servidor';
        }
        return 'Error Interno del Servidor';
      }
      return FromZeroLocalizations.of(context).translate("error_connection");
    }
    if (error is PartialSuccessError) {
      return error.titleOverride;
    }
    return FzProviderBuilder.defaultGetErrorTitle(context, error, stackTrace);
  }

  static String? defaultGetErrorSubtitle(BuildContext context, Object? error, StackTrace? stackTrace) {
    // TODO: 3 internationalize
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return 'Usted no tiene permiso para acceder al recurso solicitado';
        }
        if (error.response!.statusCode == 404) {
          return 'Por favor, notifique a su administrador de sistema';
        }
        if (error.response!.statusCode! < 500) {
          return null;
        }
        return 'Por favor, notifique a su administrador de sistema';
      }
      return FromZeroLocalizations.of(context).translate("error_connection_details");
    }
    if (error is PartialSuccessError) {
      return error.messageOverride;
    }
    return FzProviderBuilder.defaultGetErrorSubtitle(context, error, stackTrace);
  }

  static bool defaultIsErrorRetryable(Object? error, StackTrace? stackTrace) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return false;
        }
        if (error.response!.statusCode == 404) {
          return false;
        }
        if (error.response!.statusCode! < 500) {
          return false;
        }
        return false;
      }
      return true;
    }
    if (error is PartialSuccessError) {
      return false;
    }
    return FzProviderBuilder.defaultIsErrorRetryable(error, stackTrace);
  }

  static bool defaultShouldShowErrorDetails(Object? error, StackTrace? stackTrace) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return false;
        }
        if (error.response!.statusCode == 404) {
          return false;
        }
        if (error.response!.statusCode! < 500) {
          return false;
        }
        return false;
      }
      return true;
    }
    if (error is PartialSuccessError) {
      return false;
    }
    return FzProviderBuilder.defaultShouldShowErrorDetails(error, stackTrace);
  }
}

class PartialSuccessError<T> {
  final T? result;
  final int snackbarTypeOverride;
  final String titleOverride;
  final String messageOverride;
  const PartialSuccessError({
    required this.result,
    this.snackbarTypeOverride = SnackBarFromZero.warning,
    this.titleOverride = 'Éxito Parcial',
    this.messageOverride = '',
  });
}
