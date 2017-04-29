import UIKit
import Alamofire
import SwiftyJSON

protocol RequestType {
    var URLString: String { get }
    var manager: Alamofire.SessionManager { get }
    func createRequest(URLString: String, manager: Alamofire.SessionManager) -> Alamofire.DataRequest
}

protocol RequestContextType {}
extension RequestContextType where Self: RequestType {
    func create(block: @escaping (Alamofire.DataResponse<Any>) -> Void) -> Alamofire.DataRequest {
        let request = self.createRequest(URLString: URLString, manager: manager)
        request.responseJSON(completionHandler: block)
        return request
    }

    func createRequest(URLString: String, manager: Alamofire.SessionManager) -> DataRequest {
        return manager.request(URLString)
    }
}

struct GetArticleListRequestContext: RequestContextType, RequestType {
    var URLString: String {
        return "https://qiita.com/api/v2/items"
    }

    var manager: SessionManager {
        return Alamofire.SessionManager.default
    }
}

class ArticleListViewController: UIViewController, UITableViewDataSource {
    let table = UITableView()
    var articles: [[String: String?]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        table.frame = view.frame
        view.addSubview(table)
        table.dataSource = self

        title = "新着記事"

        getArticles()
        
    }

    func getArticles() {
        let context = GetArticleListRequestContext()
        let request: Alamofire.DataRequest = context.create { (response: Alamofire.DataResponse<Any>) in
            guard let object = response.result.value else {
                return
            }

            let json = JSON(object)
            json.forEach { (_, json) in
                let article: [String: String?] = [
                    "title": json["title"].string,
                    "userId": json["user"]["id"].string
                ]
                self.articles.append(article)
            }
            self.table.reloadData()
        }
        request.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let article = articles[indexPath.row]

        cell.textLabel?.text = article["title"]!
        cell.detailTextLabel?.text = article["userId"]!

        return cell
    }
}
