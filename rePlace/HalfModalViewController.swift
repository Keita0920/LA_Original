import UIKit
import MapKit
import RealmSwift

class HalfModalViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    var mapView: MKMapView!
    var annotationPin:MKAnnotation!
    @IBOutlet weak var colorLabel: UITextField!
    @IBOutlet var table:UITableView!
    @IBOutlet weak var tagNameLabel: UILabel!
    var colorList=[UIColor]()
    let gray      = UIColor.gray
    let red       = UIColor.red
    let green     = UIColor.green
    let blue      = UIColor.blue
    let cyan      = UIColor.cyan
    let yellow    = UIColor.yellow
    let magenta   = UIColor.magenta
    let orange    = UIColor.orange
    let purple    = UIColor.purple
    let brown     = UIColor.brown
    var handleColor=[UIColor]()
    let realm=try! Realm()
    var tagNameArray=[String]()
    var colorIndexNum:Int?
    var resultHandler: ((Bool) -> Void)?
    var isDeleted:Bool=false
    var object:Image!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorLabel.isEnabled=false
        colorList=[red,green,blue,cyan,yellow,magenta,orange,purple,brown,gray]
        table.delegate=self
        table.dataSource=self
        let tag=realm.objects(Tag.self)
        for i in 0..<tag.count{
            tagNameArray.append(tag[i].tagName)
            handleColor.append(colorList[tag[i].colorIndexNum])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if object.tagName != ""{
            colorLabel.backgroundColor=colorList[object.colorIndexNum]
            tagNameLabel.text=object.tagName
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(presentingViewController!)
        presentingViewController?.beginAppearanceTransition(true, animated: true)
    }
    
    //セルの数を決定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagNameArray.count
    }
    
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text=tagNameArray[indexPath.row]
        cell?.backgroundColor=handleColor[indexPath.row]
        // セルが選択された時の背景色を消す
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell!
    }
    
    // セルが選択された時に呼び出される
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        // チェックマークを入れる
        cell?.accessoryType = .checkmark
        let tag=realm.objects(Tag.self)
        colorIndexNum=tag[indexPath.row].colorIndexNum
        colorLabel.backgroundColor=colorList[colorIndexNum!]
        tagNameLabel.text=tagNameArray[indexPath.row]
        let image=realm.objects(Image.self).filter("colorIndexNum == %@",object.colorIndexNum)
        try! realm.write{image[0].colorIndexNum = tag[indexPath.row].colorIndexNum}
        let imageName=realm.objects(Image.self).filter("tagName == %@",object.tagName)
        try! realm.write{imageName[0].tagName = tagNameArray[indexPath.row]}
    }
    
    // セルの選択が外れた時に呼び出される
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        // チェックマークを外す
        cell?.accessoryType = .none
    }
    
    //ピンを削除
    @IBAction func deleteAnnnotation(){
        isDeleted=true
        if let handler = self.resultHandler {
            // 入力値を引数として渡された処理の実行
            handler(isDeleted)
        }
        try! realm.write{
            realm.delete(object)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
