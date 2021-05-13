//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//  Primary documentation is located at https://www.developers.themoviedb.org.

import Foundation

class TMDBClient {
    
    //API Key (v3 auth)
    // Registration and API Key needed to access the application
    static let apiKey = "***********************" // I cant push my private api key
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        static let requestToken = "/authentication/token/new"
        static let redirect = "?redirect_to=themoviemanager:authenticate"
        
        
        case getWatchlist
        case addToWatchlist
        case getFavoriteMovies
        case addToFavoriteMovies
        case searchMovie(String)
        case getRequestToken
        case loginRequest
        case createSessionId
        case webAuth
        case logOut
        case posterImageURL(String)
        
        var stringValue: String {
            switch self {
            case .getWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .addToWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getFavoriteMovies:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam +
                    "&session_id=\(Auth.sessionId)"
            case .addToFavoriteMovies:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .searchMovie(let query):
                return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            case .getRequestToken:
                return Endpoints.base + Endpoints.requestToken + Endpoints.apiKeyParam
            case .loginRequest:
                return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
            case .createSessionId:
                return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
            case .webAuth:
                return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + Endpoints.redirect
            case .logOut:
                return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
            case .posterImageURL(let posterPath):
                return "https://image.tmdb.org/t/p/w500\(posterPath)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL,
                                                          response: ResponseType.Type,
                                                          completion: @escaping  (ResponseType?, Error?) -> Void ) {
        print(url)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            if let responseObject = try? decoder.decode(ResponseType.self, from: data) {
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } else {
                if let errorResponse = try? decoder.decode(TMDBResponse.self, from: data) {
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL,
                                                                                   body: RequestType,
                                                                                   response: ResponseType.Type?,
                                                                                   completion: @escaping (ResponseType?, Error?)-> Void ) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                print("Error data")
                return
            }
            
            let decoder = JSONDecoder()
            if let responseObject = try? decoder.decode(ResponseType.self, from: data) {
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                print("Error decode")
            }
        }
        task.resume()
    }
    
    
    class func logOut(completion: @escaping (Bool, Error?) -> (Void)) {
        let body = LogoutRequest(sessionId: Auth.sessionId)
        var request = URLRequest(url: Endpoints.logOut.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(false, error)
                print("error")
                return
            }
            
            if let responseObject = try? JSONDecoder().decode(LogoutResponse.self, from: data) {
                if responseObject.success {
                    print("success delete")
                    Auth.requestToken = ""
                    Auth.sessionId = ""
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func getSessionId(completion: @escaping (Bool, Error?)-> (Void)) {
        let body = PostSession(requestToken: Auth.requestToken)
        
        taskForPOSTRequest(url: Endpoints.createSessionId.url, body: body, response: SessionResponse.self) { (responseObject, error) in
            if let responseObject = responseObject {
                Auth.sessionId = responseObject.sessionId
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> (Void) ) {
        
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        
        taskForPOSTRequest(url: Endpoints.loginRequest.url, body: body, response: RequestTokenResponse.self) { (responseObject, error) in
            if let responseObject = responseObject {
                Auth.requestToken = responseObject.requestToken
                print(responseObject)
                completion(true, nil)
            } else {
                completion(false, error)
                print("Error decode")
            }
        }
    }
    
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getRequestToken.url, response: RequestTokenResponse.self) { (response, error) in
            if let response = response {
                Auth.requestToken = response.requestToken
                print(Endpoints.base + Endpoints.requestToken + Endpoints.apiKeyParam)
                
                completion(true, nil)
            } else {
                completion(false, error)
                print("Data error 2")
            }
        }
    }
    
    /// Function for get user's watch list of movie
    /// - Parameter completion: return array of Movie or Error if something wrong
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.getWatchlist.url, response: MovieResults.self) { (responseObject, error) in
            if let responseObject = responseObject {
                completion(responseObject.results, nil)
            } else {
                completion ([], error)
            }
        }
    }
    
    /// Function for get favorite user's list of movie
    /// - Parameter completion: return array of Movie or Error if something wrong
    class func getFavoriteMovies(completion: @escaping ([Movie], Error?) -> (Void) ) {
        
        taskForGETRequest(url: Endpoints.getFavoriteMovies.url, response: MovieResults.self) { (responseObject, error) in
            if let responseObject = responseObject {
                DispatchQueue.main.async {
                    completion(responseObject.results, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion([], nil)
                }
            }
        }
    }
    
    class func searchMovie(query: String, completion: @escaping ([Movie], Error?) -> (Void) ) {
        
        taskForGETRequest(url: Endpoints.searchMovie(query).url, response: MovieResults.self) { (responseObject, error) in
            if let responseObject = responseObject {
                DispatchQueue.main.async {
                    completion(responseObject.results, nil)
                    print(responseObject.totalPages)
                }
            } else {
                DispatchQueue.main.async {
                    completion([], nil)
                }
            }
        }
    }
    
    class func addToWatchList(movieId: Int, watchList: Bool, completion: @escaping (Bool, Error?) -> (Void)) {
        let body = MarkWatchlist(mediaType: MediaType.movie.rawValue, mediaId: movieId, watchList: watchList)
        taskForPOSTRequest(url: Endpoints.addToWatchlist.url, body: body, response: TMDBResponse.self) { (responseObject, error) in
            if let response = responseObject {
                print("status code = \(response.statusCode) and status message =  " + "\(response.statusMessage)")
                print("added")
                DispatchQueue.main.async {
                    completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
                }
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        
    }
    
    class func addToFavoriteList(movieId: Int, watchList: Bool, completion: @escaping (Bool, Error?) -> (Void)) {
        let body = MarkFavorite(mediaType: MediaType.movie.rawValue, mediaId: movieId, favorite: watchList)
        taskForPOSTRequest(url: Endpoints.addToFavoriteMovies.url, body: body, response: TMDBResponse.self) { (responseObject, error) in
            if let response = responseObject {
                print("status code = \(response.statusCode) and status message =  " + "\(response.statusMessage)")
                print("added")
                DispatchQueue.main.async {
                    completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
                }
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        
    }
    
    class func downloadPoster(_ posterImage: String, completion: @escaping (Data?, Error?)-> (Void) ) {
        let task = URLSession.shared.dataTask(with: Endpoints.posterImageURL(posterImage).url) { (data, response, error) in
            guard let data = data else {
                print(error as Any)
                completion(nil, error)
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
     
}

