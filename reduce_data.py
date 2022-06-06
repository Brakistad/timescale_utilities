from os.path import getsize
from os import remove
from pathlib import Path
from csv import reader, writer
from csv import QUOTE_ALL
from posixpath import split

files = [
    "data-1654238363402.csv",
    "data-1654238502530.csv",
    "data-1654238826430.csv",
    "data-1654238883648.csv",
]


def split_file(file: Path):
    print(f"{file.name}: " + str(float(getsize(file)) / (10**6)) + " MB")
    if getsize(file) > 50 * (10**6):
        filename = file.name.split(".")[0]
        splitted_path1 = Path(filename + "_1.csv")
        splitted_path2 = Path(filename + "_2.csv")
        line_count = 0
        with open(file, "r") as fr:
            csv_reader = reader(fr, delimiter=",")
            for line in csv_reader:
                line_count += 1
        line_count_half = int(line_count / 2)
        with open(file, "r") as fr:
            csv_reader = reader(fr, delimiter=",")
            with open(splitted_path1, "w") as fw1, open(splitted_path2, "w") as fw2:
                csv_writer1 = writer(fw1, delimiter=",", quoting=QUOTE_ALL)
                csv_writer2 = writer(fw2, delimiter=",", quoting=QUOTE_ALL)
                i = 0
                columns_line = None
                for line in csv_reader:
                    if i == 0:
                        columns_line = line
                    elif i < line_count_half:
                        csv_writer1.writerow(line)
                    elif i >= line_count_half:
                        csv_writer2.writerow(line)
                    i += 1
        split_file(splitted_path1)
        split_file(splitted_path2)
        remove(file)
    else:
        filename = file.name.split(".")[0]
        new_path = Path(filename + "_1.csv")
        line_count = 0
        with open(file, "r") as fr:
            csv_reader = reader(fr, delimiter=",")
            for line in csv_reader:
                line_count += 1
        line_count_half = int(line_count / 2)
        with open(file, "r") as fr:
            csv_reader = reader(fr, delimiter=",")
            with open(new_path, "w") as fw:
                csv_writer1 = writer(fw, delimiter=",", quoting=QUOTE_ALL)
                i = 0
                columns_line = None
                for line in csv_reader:
                    if i == 0:
                        columns_line = line
                    else:
                        csv_writer1.writerow(line)
                    i += 1
        remove(file)


for file in files:
    split_file(Path(file))
