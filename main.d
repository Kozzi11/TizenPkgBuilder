module main;

import pkgbuilder : Parser, OperatingSystem;
import std.stdio;
import std.getopt;


void main(string[] args)
{
    string url = "http://download.tizen.org/sdk/packages-2.3/official";
    string os_name = "ubuntu";
    string os_arch = "64";
    getopt(args,
           "url", &url,
           "os_name", &os_name,
           "os_arch", &os_arch,
           );
    
    Parser parser = new Parser(url, OperatingSystem(os_name, os_arch));

    parser.run();
    parser.print();

    // Lets the user press <Return> before program returns
    stdin.readln();
}

