# Simple mongodb process management script
# By SamuelC

# should match with mongodb.conf 'dbpath'
DATA_PATH=$HOME/dev/data/current
LOG_PATH=$DATA_PATH/log
PID_PATH=$DATA_PATH
# mongodb config file location
CONF_PATH=$HOME/bin
CONF_FILE=$CONF_PATH/mongodb.conf

ulimit -n 1024

how() {
  echo "Usage: $0 [start|stop|status|rotlog]";
  echo "";
}

status() {
    PID=`cat $PID_PATH/mongodb.pid | awk '{print $1;}'`;
    #echo "DEBUG PID=[$PID]";
    if [ "x$PID" == "x" ]
    then
        echo "mongodb is NOT running."
        return 0;
    else 
        r=`ps -ef|grep mongodb.conf|grep $PID|wc -l`;
        #echo "DEBUG r=[$r]";
        if [ $r == 1 ]
        then
            ps -ef|grep $CONF_PATH/mongodb.conf|grep $PID;
            echo "mongodb is RUNNING, PID=[$PID].";
            return 1;
        elif [ $r == 0 ]
        then
            echo "mongodb is NOT running."
            return 0;
        fi
    fi
    echo "ALERT! System abnormality found!";
    return 2;
}

start() {
    echo "Checking status..."; status;
    if [ $? != 0 ]
    then
        echo "MongoDB process already running."
        exit 1;
    fi
    echo "Starting mongodb process...";
    DSTR=`date "+%Y%m%d%H%M"`;
    mongod --config $CONF_FILE  --logpath $LOG_PATH/mongodb_$DSTR.log
    PID=`cat $PID_PATH/mongodb.pid | awk '{print $1;}'`
    unlink $LOG_PATH/current.log
    ln -s $LOG_PATH/mongodb_$DSTR.log $LOG_PATH/current.log
    echo "Process ID: [$PID]"; 
    exit 0;
}

stop() {
    echo "Stopping mongodb process....";
    echo "kill -15 `cat $PID_PATH/mongodb.pid | awk '{print $1;}'`";
    kill -15 `cat $PID_PATH/mongodb.pid | awk '{print $1;}'`;
}

rotlog() {
    PID=`cat $PID_PATH/mongodb.pid | awk '{print $1;}'`
    echo "Trigger log rotation..."
    echo "kill -SIGUSR1 $PID"
    kill -SIGUSR1 $PID
    exit 0;
}

OPT="x$1";
if [ $OPT == "x" ]
then 
    how;
    exit 0;
fi

case $OPT in 
    "xstatus") status;
        ;;
    "xstart") start;
        ;;
    "xstop") stop;
        ;;
    "xrotlog") rotlog;
        ;;
    *)  how;
        ;;
esac
