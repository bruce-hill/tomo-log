use <time.h>
use <stdio.h>

timestamp_format := CString("%F %T")

log_writers : @[func(text:Text, close:Bool=no -> Result)]

func _timestamp(->Text)
    c_str := C_code:CString`
        char *str = GC_MALLOC_ATOMIC(20);
        time_t t; time(&t);
        struct tm *tm_info = localtime(&t);
        strftime(str, 20, "%F %T", tm_info);
        str
    `
    return c_str.as_text()

func info(text:Text, newline=yes)
    say("\[2]⚫ $text\[]", newline)
    for write in log_writers
        write("$(_timestamp()) [info]  $text\n")!

func debug(text:Text, newline=yes)
    say("\[32]🟢 $text\[]", newline)
    for write in log_writers
        write("$(_timestamp()) [debug] $text\n")!

func warn(text:Text, newline=yes)
    say("\[33;1]🟡 $text\[]", newline)
    for write in log_writers
        write("$(_timestamp()) [warn]  $text\n")!

func error(text:Text, newline=yes)
    say("\[31;1]🔴 $text\[]", newline)
    for write in log_writers
        write("$(_timestamp()) [error] $text\n")!

func log(text:Text, tag:Text="log", emoji="🔵", color="\[34]", newline=yes)
    say("$color$emoji $text\[]", newline)
    tag = "[$tag]".right_pad("[error]".length)
    for write in log_writers
        write("$(_timestamp()) $tag $text\n")!

func add_logfile(file:Path, append:Bool=yes)
    log_writers.insert(file.writer(append=append))

func main()
    add_logfile((./log.txt), append=no)
    >> info("Hello")
    >> debug("Hello")
    >> warn("Hello")
    >> error("Hello")
    >> log("Hello")
    >> log("Hello", tag="penguin", emoji="🐧", color="\[36]")

