import time
import re
import pyperclip
from datetime import datetime


def log(message):
    """自定义带时间戳的日志输出函数"""
    # 获取当前时间并格式化为 年-月-日 时:分:秒
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{current_time}] {message}")


def process_typst_text(text):
    if not isinstance(text, str) or not text.strip():
        return text

    # 步骤 1：脱去 Markdown 加粗语法 **文本** -> 文本
    # 使用 \1 将匹配到的内容替换为括号内捕获的第一组文本
    text = re.sub(r"\*\*(.*?)\*\*", r"\1", text, flags=re.DOTALL)

    # 先替换块级公式 $$ ... $$ -> #mitex(`...`)
    # 使用 flags=re.DOTALL 让 . 能够匹配换行符，从而支持多行公式
    text = re.sub(r"\$\$(.*?)\$\$", r"#mitex(`\1`)", text, flags=re.DOTALL)

    # 再替换行内公式 $ ... $ -> #mi(`...`)
    # 因为步骤 1 已经把所有 $$ 消耗掉了，这里直接匹配单 $ 是安全的
    text = re.sub(r"\$(.*?)\$", r"#mi(`\1`)", text)

    return text


def main():
    log("🚀 Typst Mitex 剪贴板监听已启动...")
    log("轮询间隔：1秒。自动处理：#mi(` 公式 `)、#mitex(` 公式 `) 以及去除 **加粗**。")
    log("按下 Ctrl+C 终止程序。")

    recent_value = ""

    while True:
        try:
            current_value = pyperclip.paste()

            if current_value != recent_value:
                new_value = process_typst_text(current_value)

                # 只要内容发生了变化（去除了加粗，或者替换了公式）
                if new_value != current_value:
                    pyperclip.copy(new_value)
                    log("✓ 剪贴板已清洗并转换")
                    recent_value = new_value
                else:
                    recent_value = current_value

        except Exception:
            pass

        time.sleep(1)


if __name__ == "__main__":
    main()
