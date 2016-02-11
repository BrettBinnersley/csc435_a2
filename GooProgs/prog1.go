package main

var x, y int = 3, 4;
const a,b int = 7,8;
const c,d = 10,11;
type BookInfo struct { subject string; book_id int }
type Books struct { title string; author string; info BookInfo }
func main() {
    var Book1 Books
    Book1.title = "Go Programming"
}