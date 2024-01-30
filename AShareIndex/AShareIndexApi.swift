//
//  AShareIndexApi.swift
//  AShareIndex
//
//  Created by Kyle Lin on 2024/1/29.
//

import Cocoa
import Alamofire

struct AShareIndexItem: Codable {
    let day: String
    let close: String
}

class AShareIndexApi {
    static func get(_ code: String) -> DataRequest {
        let url = "https://hq.sinajs.cn/?list=" + code
        let headers: HTTPHeaders = [
            "Referer": "https://finance.sina.com.cn",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        return AF.request(url, headers: headers)
    }
    static func list(_ code: String, scale: Int, datalen: Int) -> DataRequest {
        let url = "https://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol=\(code)&scale=\(scale)&ma=no&datalen=\(datalen)"
        let headers: HTTPHeaders = [
            "Referer": "https://finance.sina.com.cn",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        return AF.request(url, headers: headers)
    }
}
