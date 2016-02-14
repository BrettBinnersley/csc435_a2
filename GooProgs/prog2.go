package main

type Books struct { title string; author string; info BookInfo }

type BookInfo struct { subject string; book_id int }

func main() {
 var Book1 Books
 Book1.title = "Go Programming"
}
