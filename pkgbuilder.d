module pkgbuilder;

import std.stdio;
import std.net.curl : byLine;
import std.conv : to;
import std.algorithm : splitter;
import std.range : array;

class Parser
{
    typeof(byLine("")) content;
    string url;
    string os;
    PackageInfo[string] packagesInfo;

    this(string url, string os)
    {
        this.url = url;
        this.os = os;
        this.content = byLine(url ~ "/" ~ "pkg_list_" ~ os);
    }

    void run()
    {
        PackageInfo pi;
        foreach (line; content) {
            auto lineData = splitter(line, ":");
            if (!lineData.empty) {           
                import std.string : strip;
                
                string field = strip(to!string(lineData.front));
                string value;
                
                lineData.popFront;
                if (!lineData.empty) {
                    value = strip(to!string(lineData.front));
                }
                
                pi.fillProperty(field, value);
            } else {
                packagesInfo[pi.name] = pi;
                pi = PackageInfo();
            }
        }
    }

    void print()
    {
        size_t index;
        foreach (pName, pData; packagesInfo) {
            writeln(to!string(++index) ~ ": " ~ pName ~ " : " ~ pData.name);
        }
    }
}


private:

enum PropertyName : string {
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

struct PackageInfo {
    string name;
    string ver;
    string arch;
    string path;
    string checksum;
    string desc;
    string sdeps;
    string sconflicts;
    string[] otherDeps;
    PackageInfo[] deps;
    PackageInfo[] conflicts;
    
    void fillProperty(string property, string value) {
        PropertyName pn = cast(PropertyName)(property);
        with(PropertyName) final switch (pn) {
            case Package:
                name = value;
                break;
            case Version:
                ver = value;
                break;
            case OS:
                arch = "64";
                break;
            case Path:
                path = value;
                break;
            case SHA256:
                checksum = value;
                break;
            case CPrerequisites:
                otherDeps ~= value;
                break;
            case Description:
                desc = value;
                break;
            case InstallDependency:
                sdeps = value;
                break;
            case Conflicts:
                sconflicts = value;
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