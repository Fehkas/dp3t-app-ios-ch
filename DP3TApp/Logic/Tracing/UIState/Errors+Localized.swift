
/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import DP3TSDK

protocol CodedError {
    var errorCodeString: String? { get }
}

let CodeErrorUnexpected = "IUKN"

extension DP3TTracingError: LocalizedError, CodedError {
    public var errorDescription: String? {
        let unexpected = "unexpected_error_title".ub_localized
        switch self {
        case let .networkingError(error):
            return error.localizedDescription
        case .caseSynchronizationError, .userAlreadyMarkedAsInfected:
            return unexpected.ub_localized
        case let .databaseError(error):
            return error?.localizedDescription
        case .bluetoothTurnedOff:
            return "bluetooth_turned_off".ub_localized // custom UI, this should never be visible
        case .permissonError:
            return "bluetooth_permission_turned_off".ub_localized // custom UI, this should never be visible
        case let .exposureNotificationError(error: error):
            let nsError = error as NSError
            if nsError.domain == "ENErrorDomain", nsError.code == 4 {
                return "user_cancelled_key_sharing_error".ub_localized
            }
            return error.localizedDescription
        }
    }

    var errorCodeString: String? {
        switch self {
        case let .networkingError(error: error):
            return error.errorCodeString
        case .caseSynchronizationError(errors: _):
            return "ICASYN"
        case .databaseError(error: _):
            return "IDBERR"
        case .bluetoothTurnedOff:
            return "IBLOFF"
        case .permissonError:
            return "IPERME"
        case .userAlreadyMarkedAsInfected:
            return "IUAMAI"
        case let .exposureNotificationError(error: error):
            let nsError = error as NSError
            return "IEN\(nsError.code)" // Should match code below
        }
    }

    /// We know that Exposure Notification Error with Code 13 is not recoverable
    static let nonRecoverableSyncErrorCode = "IEN13"
}

extension DP3TNetworkingError: LocalizedError, CodedError {
    public var errorDescription: String? {
        switch self {
        case .networkSessionError(error: _):
            return "network_error".ub_localized

        case .notHTTPResponse: fallthrough
        case .HTTPFailureResponse: fallthrough
        case .noDataReturned: fallthrough
        case .couldNotParseData: fallthrough
        case .couldNotEncodeBody: fallthrough
        case .batchReleaseTimeMissmatch: fallthrough
        case .timeInconsistency: fallthrough
        case .jwtSignatureError:
            return "unexpected_error_title".ub_localized
        }
    }

    var errorCodeString: String? {
        switch self {
        case let .networkSessionError(error: error):
            let nsError = error as NSError
            return "INET\(nsError.code)"
        case .notHTTPResponse:
            return "INORES"
        case let .HTTPFailureResponse(status: status):
            return "IRST\(status)"
        case .noDataReturned:
            return "INODAT"
        case .couldNotParseData(error: _, origin: _):
            return "IPARS"
        case .couldNotEncodeBody:
            return "IBODEN"
        case .batchReleaseTimeMissmatch:
            return "IBRTMM"
        case .timeInconsistency(shift: _):
            return "ITIMIN"
        case .jwtSignatureError(code: _, debugDescription: _):
            return "IJWTSE"
        }
    }
}

extension NetworkError: LocalizedError, CodedError {
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "network_error".ub_localized
        case .statusError(code: _): fallthrough
        case .parseError:
            return "unexpected_error_title".ub_localized
        }
    }

    var errorCodeString: String? {
        switch self {
        case .networkError:
            return "ICNETE"
        case let .statusError(code: code):
            return "IBST\(code)"
        case .parseError:
            return "ICPARS"
        case let .unexpected(error: error):
            let nsError = error as NSError
            return "IUNXN\(nsError.code)"
        }
    }
}
extension CertificateValidationError: LocalizedError, CodedError {
    var errorDescription: String? {
        return "certificate_validation_error".ub_localized
    }

    var errorCodeString: String? {
        return "ICERT"
    }
}
