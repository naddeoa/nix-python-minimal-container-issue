from faster_fifo import Queue


def run():
    queue = Queue()
    queue.put(1)
    print(queue.get())
    queue.close()


if __name__ == "__main__":
    run()
