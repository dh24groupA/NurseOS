//
//  Azureconnect.swift
//  NurseOS
//
//  Created by デジタルヘルス on 2024/11/15.
//

import Foundation

func fetchDataFromAzureAPI() {
    // URLの設定（エンドポイントはAzureポータルで取得）
    let url = URL(string: "https://your-database-endpoint-url")!

    // HTTPリクエストの設定
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("YOUR_API_KEY", forHTTPHeaderField: "Authorization") // 必要に応じてAPIキーを追加

    // URLSessionでデータ取得
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error:", error ?? "Unknown error")
            return
        }

        // JSONデコード処理
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            print("Response from Azure:", jsonResponse)
        } catch let parsingError {
            print("Error while parsing JSON:", parsingError)
        }
    }
    task.resume()
}
