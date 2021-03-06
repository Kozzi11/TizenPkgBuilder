﻿module pkgbuilder;

import std.stdio;
import std.net.curl : byLine;
import std.conv : to;
import std.algorithm : splitter;
import std.range : array;
import std.array : appender;

final class PkgBuilder
{
    private Parser parser;
    private auto pkg_builds = appender!(PkgBuild[])();

    this(string url, string osName, string osArch)
    {
        this(new Parser(url, OperatingSystem(osName, osArch)));
    }

    this(Parser parser)
    {
        if (parser.packages_info is null)
        {
            parser.run();
        }
        this.parser = parser;
    }

    void generate()
    {
        preparePkgBuilds();
    }

    private void preparePkgBuilds()
    {

    }
}

private:

final class Parser
{
    typeof(byLine("")) content;
    string url;
    OperatingSystem os;
    PackageInfo[string] packages_info;

    this(string url, OperatingSystem os)
    {
        this.url = url[$-1] == '/' ? url : url ~ "/";
        this.os = os;
        this.content = byLine(url ~ "/" ~ "pkg_list_" ~ os);
    }
    
    void run()
    {
        PackageInfo pi;
        foreach (line; content)
        {
            auto line_data = splitter(line, ":");
            if (!line_data.empty)
            {
                import std.string : strip;
                
                string field = strip(to!string(line_data.front));
                string value;
                
                line_data.popFront;
                if (!line_data.empty)
                {
                    value = strip(to!string(line_data.front));
                }
                
                pi.fillProperty(field, value);
            }
            else
            {
                packages_info[pi.name] = pi;
                pi = PackageInfo();
            }
        }
    }
    
    void print()
    {
        size_t index;
        foreach (pName, pData; packages_info)
        {
            writeln(to!string(++index) ~ ": " ~ pName ~ " : " ~ pData.name);
        }
    }
}

struct OperatingSystem
{
    
    string name;
    string arch;
    
    alias toString this;
    
    this(string name, string arch)
    {
        this.name = name;
        this.arch = arch;
    }
    
    this(string os)
    {
        auto result = splitter(os, "-").array;
        if (result.length == 2)
        {
            name = result[0];
            arch = result[1];
        }
        else
        {
            throw new Exception("Bad OS");
        }
    }
    
    string toString()
    {
        return name ~ "-" ~ arch;
    }
}

enum PropertyName : string
{
    Package = "Package",
    Version = "Version",
    OS = "OS",
    BuildHostOS = "Build-host-os",
    Maintainer = "Maintainer",
    Path = "Path",
    Origin = "Origin",
    SHA256 = "SHA256",
    Size = "Size",
    UncompressedSize = "Uncompressed-size",
    Description = "Description",
    InstallDependency = "Install-dependency",
    BuildDependency = "Build-dependency",
    SourceDependency = "Source-dependency",
    Conflicts = "Conflicts",
    Attribute = "Attribute",
    CDefault = "C-default",
    COrder = "C-order",
    CPrerequisites = "C-Prerequisites",
    CSelectedGroup = "C-SelectedGroup",
    CUnSelectedGroup = "C-UnSelectedGroup",
    Label = "Label",
}

struct PackageInfo
{
    string name;
    string ver;
    OperatingSystem os;
    string path;
    string checksum;
    string desc;
    string deps;
    string conflicts;
    string cdeps;
    
    void fillProperty(string property, string value)
    {
        PropertyName pn = cast(PropertyName)(property);
        with(PropertyName) final switch (pn)
        {
            case Package:
                name = value;
                break;
            case Version:
                ver = value;
                break;
            case OS:
                os = OperatingSystem(value);
                break;
            case Path:
                path = value;
                break;
            case SHA256:
                checksum = value;
                break;
            case CPrerequisites:
                cdeps = value;
                break;
            case Description:
                desc = value;
                break;
            case InstallDependency:
                deps = value;
                break;
            case Conflicts:
                conflicts = value;
                break;
            case Attribute:
            case Label:
            case CSelectedGroup:
            case CUnSelectedGroup:
            case CDefault:
            case COrder:
            case BuildDependency:
            case SourceDependency:
            case BuildHostOS:
            case Maintainer:
            case Size:
            case UncompressedSize:
            case Origin:
                break;
                /*default:
                 writeln(property);*/
        }
    }
}

struct PkgBuild
{
    string pkgname;
    string pkgver;
    string pkgdesc;
    string arch;
    auto groups = appender!(string[])();

}