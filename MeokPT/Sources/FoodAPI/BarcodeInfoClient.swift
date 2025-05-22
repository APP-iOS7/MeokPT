import Alamofire
import Foundation
import ComposableArchitecture

private enum BarcodeAPIConstants {
    static let keyId = "d0ce663b8a8e47449b98"
    static let serviceId = "C005"
    static let dataType = "json"
    static let defaultStartIdx = "1"
    static let defaultEndIdx = "1"
    static let baseURL = "https://openapi.foodsafetykorea.go.kr/api"
}

struct FullBarcodeResponse: Decodable, Equatable {
    let responseData: BarcodeAPIResponseContainer?

    private enum CodingKeys: String, CodingKey {
        case responseData = "C005"
    }
}

struct BarcodeAPIResponseContainer: Decodable, Equatable {
    let total_count: String
    let row: [BarcodeInfoItem]?
    let RESULT: BarcodeAPIResult
}

struct BarcodeInfoItem: Decodable, Equatable {
    let PRDLST_REPORT_NO: String?
    let PRDLST_NM: String?
    let BAR_CD: String?
    let BSSH_NM: String?
}

struct BarcodeAPIResult: Decodable, Equatable {
    let MSG: String
    let CODE: String
}

struct BarcodeInfoClient {
    var fetchItemReportNo: (_ barcode: String) async throws -> String?
}

extension BarcodeInfoClient: DependencyKey {
    static let liveValue = Self(
        fetchItemReportNo: { barcode in
            let path = "\(BarcodeAPIConstants.keyId)/\(BarcodeAPIConstants.serviceId)/\(BarcodeAPIConstants.dataType)/\(BarcodeAPIConstants.defaultStartIdx)/\(BarcodeAPIConstants.defaultEndIdx)"
            let fullURLString = "\(BarcodeAPIConstants.baseURL)/\(path)/BRCD_NO=\(barcode)"

            guard let url = URL(string: fullURLString) else {
                throw APIError.urlError
            }
            print("Requesting Barcode API URL: \(url.absoluteString)")

            do {
                let response = await AF.request(url, method: .get)
                                      .serializingDecodable(FullBarcodeResponse.self)
                                      .response
                
                switch response.result {
                case .success(let fullBarcodeResponse):
                    guard let responseData = fullBarcodeResponse.responseData else {
                        throw APIError.decodingError("Barcode API response structure unexpected (missing \(BarcodeAPIConstants.serviceId) key).")
                    }

                    if responseData.RESULT.CODE == "INFO-000" {
                        let totalCountString = responseData.total_count
                        if let totalCount = Int(totalCountString), totalCount > 0 {
                            return responseData.row?.first?.PRDLST_REPORT_NO
                        } else {
                            return nil
                        }
                    } else {
                        throw APIError.apiServiceError(resultCode: responseData.RESULT.CODE, originalMsg: responseData.RESULT.MSG)
                    }
                case .failure(let afError):
                    if let underlyingError = afError.underlyingError as? DecodingError {
                        throw APIError.decodingError(String(describing: underlyingError))
                    } else if afError.responseCode != nil {
                        throw APIError.requestFailed("HTTP \(afError.responseCode ?? -1): \(afError.localizedDescription)")
                    } else {
                        throw APIError.requestFailed(afError.localizedDescription)
                    }
                }
            } catch let error as APIError {
                throw error
            } catch {
                throw APIError.unknownError
            }
        }
    )
}

extension DependencyValues {
    var barcodeInfoClient: BarcodeInfoClient {
        get { self[BarcodeInfoClient.self] }
        set { self[BarcodeInfoClient.self] = newValue }
    }
}
