//
//  NetworkManager.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func fetchData<T: Codable>(from endpoint: MovieAPIProvider
                               , responseType: T.Type, completion: @escaping (T?,LocalizedError?) -> Void)
    func loadImage(from imageUrl: String, completion: @escaping (Data?) -> Void)

}
class NetworkManager: NetworkManagerProtocol {

    func fetchData<T: Codable>(from endpoint: MovieAPIProvider
                               , responseType: T.Type, completion: @escaping (T?,LocalizedError?) -> Void) {
        guard let url = URL(string: endpoint.urlString) else {
            completion(nil,APIError.endpointUnavailable)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                completion(nil,APIError.responseMalformed)
                return
            }
            guard let data = data  else {
                completion(nil,APIError.emptyResponse)
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(decodedData,nil)

            } catch {
                completion(nil,APIError.decodingFailure)
            }
        }
        task.resume()
    }
    func loadImage(from imageUrl: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(imageUrl)") else {
            print("error in create image url")
            completion(nil)
            return
        }
        print(url)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid data or response")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }

}
