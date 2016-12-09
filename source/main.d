module main;

import core.time;

import std.datetime;
import std.array;
import std.stdio;
import std.file;
import std.conv;
import std.string;
import std.algorithm;
import page;


class Snippet
{
public:
    this(string mdFile)
    {
        this.markdownFile = mdFile;
        this._modTime = getLastModificationDate(mdFile);
        this._createTime = getCreationDate(mdFile);
    }

    string title()
    {
        return markdownFile[7..$-3];
    }

    string anchorName()
    {
        dchar[dchar] transTable1 = [' ' : '-'];
        return translate(title(), transTable1);
    }

    SysTime getLastModificationDate(string mdFile)
    {
        try
        {
            import dateparser;
            import std.process;
            auto git = execute(["git", "log", "-1", "--format=%cd", mdFile]);
            if (git.status != 0)
                throw new Exception("Couldn't get last mod with git");

            string dateStr = strip(chomp(git.output));
            SysTime mod = parse(dateStr);
            return mod;
        }
        catch(Exception e)
        {
            // Usualy happens when the snippet is not yet commited
            return Clock.currTime();
        }
    }

    SysTime getCreationDate(string mdFile)
    {
        try
        {
            import dateparser;
            import std.process;
            auto git = execute(["git", "log", "--format=%aD", "--reverse", "--follow", mdFile]);
            if (git.status != 0)
                throw new Exception("Couldn't get creation time with git");

            string[] outputs = splitLines(git.output);
            if (outputs.length < 1)
                throw new Exception("Couldn't get creation time with git");

            string dateStr = strip(chomp(outputs[0]));
            SysTime mod = parse(dateStr);
            return mod;
        }
        catch(Exception e)
        {
            // Usualy happens when the snippet is not yet commited
            return Clock.currTime();
        }
    }

    SysTime modTime()
    {
        return _modTime;
    }

    SysTime createTime()
    {
        return _createTime;
    }

    string lastModifiedString()
    {
        if (_modTime.year == _createTime.year
            && _modTime.month == _createTime.month
            && _modTime.day == _createTime.day)
            return format("Created %s", _createTime.toFriendlyString());
        return format("Modified %s, created %s", _modTime.toFriendlyString(), _createTime.toFriendlyString());
    }

private:
    string markdownFile;
    SysTime _modTime;
    SysTime _createTime;

}

void main(string[] args)
{
    Snippet[] snippets;

    // finds all snippets by enumarating Markdown
    auto mdFiles = filter!`endsWith(a.name,".md")`(dirEntries("content",SpanMode.depth));
    foreach(md; mdFiles)
        snippets ~= new Snippet(md);

    // Sort tips by last change time
    bool sortByLastChange = true;
    if (sortByLastChange)
        snippets = sort!"a.modTime > b.modTime"(snippets).array;

    auto page = new Page("index.html");

    with(page)
        {
            writeln("<!DOCTYPE html>");
            push("html");
                push("head");

                    writeln("<meta charset=\"utf-8\">");
                    writeln("<meta name=\"description\" content=\"Effective D Programming Language.\">");
                    push("style", "type=\"text/css\"  media=\"all\" ");
                        appendRawFile("reset.css");
                        appendRawFile("common.css");
                        appendRawFile("hybrid.css");
                    pop();
                    writeln("<link href='//fonts.googleapis.com/css?family=Inconsolata' rel='stylesheet' type='text/css'>");

                    push("title");
                    write("Snippets for the D programming language");
                    pop;
                pop;
                push("body");
                    write(`<script>`
`(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){`
`(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),`
`m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)`
`})(window,document,'script','//www.google-analytics.com/analytics.js','ga');`
`ga('create', 'UA-71912218-1', 'auto');`
`ga('send', 'pageview');</script>`);

                    writeln("<script src=\"highlight.pack.js\"></script>");
                    writeln("<script>hljs.initHighlightingOnLoad();</script>");

                    push("header");
                        push("img", "id=\"logo\" src=\"d-logo.svg\"");
                        pop;
                        push("div", "id=\"title\"");
                            writeln("Snippets for the D Programming Language");
                        pop();
                    pop;

                    push("nav");
                        foreach(snippet; snippets)
                        {
                            push("div", `class="item-nav"`);
                                push("a", "href=\"#" ~ snippet.anchorName() ~ "\"");
                                    writeln(snippet.title());
                                pop;
                                push("span", `style=" color:rgb(158,158,158); font-size: 0.7em; float: right;"`);
                                    writeln(" " ~ snippet.lastModifiedString());
                                pop;
                            pop;
                        }
                    pop;

                    push("div", "class=\"container\"");
                        foreach(snippet; snippets)
                        {
                            push("a", "name=\"" ~ snippet.anchorName() ~ "\"");
                            pop;
                            push("div", "class=\"snippet\"");
                                push("a", "class=\"permalink\" href=\"#" ~ snippet.anchorName() ~ "\"");
                                    writeln("Link");
                                pop;
                                appendMarkdown(snippet.markdownFile);
                            pop;
                        }
                    pop;
                    writeln("<a href=\"https://github.com/lindt/snippets/\"><img style=\"position: absolute; top: 0; right: 0; border: 0;\" src=\"https://camo.githubusercontent.com/38ef81f8aca64bb9a64448d0d70f1308ef5341ab/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67\" alt=\"Fork me on GitHub\" data-canonical-src=\"https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png\"></a>");


                     push("footer");

                        push("h2");
                            writeln("Why Snippets?");
                        pop;

                        push("p");
                            writeln(`D is often praised for its unbounded power. But power needs availability.<br><br>`~

                                    ` You may hear about every feature a language has to offer, for example after going through the reference book.<br><br>`~
                                    `That does not mean you'll feel comfortable using these features, or figure out how they fit together.<br><br>`~

                                    `When I discovered D in 2007, I thought its learning curve was gentle. I already knew a subset of it and the language was simpler back then. It all felt glorious and familiar.<br><br>`~

                                    `The truth took years to unfold. I had skipped the learning phase because of this perceived familiarity. But D is a language of its own that needs dedicated learning like any other. I had to expand my "subset of confidence", feature by feature.<br><br>`~

                                    `This unexpected difficulty is aggravated by the fact information is scattered in different places (wiki, language documentation, D specification, D forums...).`~
                                    `Sometimes valuable information can be hard to come by. It doesn't help that some of the resources implicitely assume that your time has little value.</strong><br><br>`);
                        pop();

                        push("h2");
                            writeln("About");
                        pop;

                        push("p");
                            writeln(`Snippets from the <a href="https://github.com/d-muc/">Munich D Programmers</a>.`);
                        pop();
                    pop;
                pop;
            pop;
        }
}

string toFriendlyString(SysTime time)
{
    string result;
    int day = time.day;
    int month = time.month;
    int year = time.year;

    static immutable string[12] months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    result ~= months[month-1];
    result ~= " ";

    result ~= to!string(time.day);
    result ~= `<span class="sub">`;
    if (day == 1)
        result ~= "st";
    else if (day == 2)
        result ~= "nd";
    else if (day == 3)
        result ~= "rd";
    else
        result ~= "th";
    result ~= "</span>";
    result ~= " ";

    result ~= to!string(year);
    return result;
}
