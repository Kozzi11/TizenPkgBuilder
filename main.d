module main;

import pkgbuilder : Parser;
import std.stdio;
import std.getopt;


void main(string[] args)
{
    string url = "http://download.tizen.org/sdk/packages-2.3/official";
    string os = "ubuntu-64";
    getopt(args,
           "url", &url,
           "os", &os
           );
    
    Parser parser = new Parser(url, os);

    parser.run();
    parser.print();

    // Lets the user press <Return> before program returns
    stdin.readln();
}

