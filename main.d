module main;

import pkgbuilder : Parser, OperatingSystem, PkgBuilder;
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

    PkgBuilder pkgBuilder = new PkgBuilder(url, os_name, os_arch);
    pkgBuilder.generate();

    // Lets the user press <Return> before program returns
    stdin.readln();
}

