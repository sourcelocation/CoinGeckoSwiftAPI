import Foundation

class CoinGecko {
    
    /// Contains all info about coins, but not the prices, market cap etc.
    private var allCoins: [Coin] = []
    
    init() {
        fetch()
    }
    
    func fetch(completion: (() -> Void)? = nil) {
        array(from: "https://api.coingecko.com/api/v3/coins/list") { array in
            for dict in array! {
                guard let d = dict as? [String:Any] else { return }
                
                self.allCoins.append(Coin(id: d["id"] as? String, symbol: d["symbol"] as? String, name: d["name"] as? String))
            }
            completion?()
        }
    }
    
    func coins(ids: [String] = [], sorting: Sorting = .market_cap_desc, perPage: Int = 150, page: Int = 1, completion: @escaping ([Coin]) -> Void) {
        var url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=\(sorting.rawValue)&per_page=\(perPage)&page=\(page)&sparkline=false"
        if !ids.isEmpty {
            url.append("&ids=\(ids.joined(separator: ","))")
        }
        array(from: url, completion: { array in
            var coins:[Coin] = []
            
            for dict in array! {
                guard let d = dict as? [String:Any] else { return }
                coins.append(Coin(id: d["id"] as? String, symbol: d["symbol"] as? String, name: d["name"] as? String, imageURL: d["image"] as? String, price: d["current_price"] as? Double, marketCap: d["market_cap"] as? Double, marketCapRank: d["market_cap_rank"] as? Double, totalVolume: d["total_volume"] as? Double, high24h: d["high_24h"] as? Double, low24h: d["low_24h"] as? Double, priceChange24h: d["price_change_24h"] as? Double, priceChangePercentage24h: d["price_change_percentage_24h"] as? Double, ath: d["ath"] as? Double))
            }
            
            completion(coins)
        })
    }
    
    func search(string: String, completion: @escaping ([Coin]) -> Void) {
        var idsToSearch:[String] = []
        
        for coin in allCoins {
            if coin.id!.lowercased().contains(string.lowercased()) || coin.name!.lowercased().contains(string.lowercased()) || coin.symbol!.lowercased().contains(string.lowercased()) {
                idsToSearch.append(coin.id! )
            }
        }
        
        coins(ids: idsToSearch, sorting: .market_cap_desc, perPage: 250, page: 1) { coins in
            completion(coins)
        }
    }
    
    func history(for coin:Coin, from date1:Date, to date2:Date, completion: @escaping ([PricePoint]) -> Void) {
        guard let coinId = coin.id else { completion([]); return }
        dictionary(from: "https://api.coingecko.com/api/v3/coins/\(coinId)/market_chart/range?vs_currency=usd&from=\(date1.timeIntervalSince1970)&to=\(date2.timeIntervalSince1970)") { dictionary in
            let array = dictionary!["prices"] as! [[Double]]
            var points:[PricePoint] = []
            
            for point in array {
                points.append(PricePoint(price: point[1], unixTimestamp: point[0]))
            }
            
            completion(points)
        }
    }
    
    private func dictionary(from url: String, completion: @escaping ([String: Any]?) -> Void) {
        text(from: url, completion: { response in
            completion(self.convertToDictionary(response))
        })
    }
    private func array(from url: String, completion: @escaping ([Any]?) -> Void) {
        text(from: url, completion: { response in
            completion(self.convertToArray(response))
        })
    }
    private func text(from url: String, completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let string = String(data: data!, encoding: .utf8) else { completion(""); return }
            completion(string)
        }.resume()
    }
    
    fileprivate func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    fileprivate func convertToArray(_ text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    private func dummy() {
        print("Hello world!")
    }
    
    
    enum Sorting: String {
        case gecko_desc, gecko_asc, market_cap_asc, market_cap_desc, volume_asc, volume_desc, id_asc, id_desc
    }
    struct PricePoint {
        var price: Double
        var unixTimestamp: TimeInterval
        
        var date: Date {
            get {
                return Date(timeIntervalSince1970: unixTimestamp)
            } set {
                unixTimestamp = newValue.timeIntervalSince1970
            }
        }
    }
}

struct Coin {
    var id: String?
    var symbol: String?
    var name: String?
    var imageURL: String?
    
    var price: Double?
    
    var marketCap: Double?
    var marketCapRank: Double?
    var totalVolume: Double?
    
    var high24h: Double?
    var low24h: Double?
    
    var priceChange24h: Double?
    var priceChangePercentage24h: Double?
    
    var ath:Double?
}
