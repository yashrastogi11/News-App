import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:news_app/data.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Data data;
  List<Articles> articles;


  Future<void> fetchArticles() async{
    var res = await http.get("https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=c27a32745a7145bf951c3db1746c645d");
    var decRes = jsonDecode(res.body);
    print(decRes);
    data = Data.fromJson(decRes);
    articles = data.articles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("News App"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        elevation: 3.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchArticles,
        child: FutureBuilder(
          future: fetchArticles(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
                return Text("Press button to start.");
              case ConnectionState.active:
              case ConnectionState.waiting:
              return Center(
                child: FlareActor(
                  "images/Brain.flr",
                  animation: "brain",
                  alignment: Alignment(0.05,-1.0),
                  fit: BoxFit.cover,
                ),
              );
              case ConnectionState.done:
                if (snapshot.hasError) return errorData(snapshot);
                return articleList();
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Error: ${snapshot.error}"),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            onPressed: () {
              fetchArticles();
              setState(() {});
            },
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  ListView articleList(){
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) => Card(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        color: Colors.grey[100],
        elevation: 1.0,

        child: Row(
          children: <Widget>[
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  InkWell(
                    onTap: () async {
                      if (await canLaunch(articles[index].url)) {
                        await launch(articles[index].url);
                      }
                      else {
                        throw 'Could not display the article.';
                      }
                      if (!mounted)
                        return;
                    },


                    child: Container(
                      width: MediaQuery.of(context).size.width/3.0,
                      child: Image.network(articles[index].urlToImage, gaplessPlayback: true)
                    ),
                  ),
                  SizedBox(
                    height: 7.5,
                  ),
                  Chip(
                    label: new Text(articles[index].publishedAt,
                      style: TextStyle(
                          fontSize: 10.0
                      ),
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                  Chip(
                    label: new Text(articles[index].author,
                      style: TextStyle(
                          fontSize: 10.0
                      ),
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 20.0,
            ),

            new Flexible(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      if (await canLaunch(articles[index].url)) {
                        await launch(articles[index].url);
                      }
                      else {
                        throw 'Could not display the article.';
                      }
                      if (!mounted)
                        return;
                    },
                    child: Text(
                      articles[index].title,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Text(
                    articles[index].description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],

        ),

      ),
    );
  }
}

