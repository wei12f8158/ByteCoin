
import Foundation
import UIKit

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://api.nomics.com/v1/currencies/ticker?ids=BTC"
    let apiKey = "55370e51dc8770077b80c29ba7cfad7dba3d0e8c"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)&convert=\(currency)&key=\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData){
                        let priceSring = String(format: "%.2f", bitcoinPrice)
                        print(priceSring)
                        self.delegate?.didUpdatePrice(price: priceSring, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        
        let decodeJSON = JSONDecoder()
        do {
            let decodeData = try decodeJSON.decode([CoinData].self, from: data).first
            let lastPrice = decodeData!.price
            let lastPriceDouble = Double(lastPrice)!
            return lastPriceDouble
            
        }catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
