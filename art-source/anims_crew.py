"""MARGIN — animated portraits: blink (idle) and talk, in normal and worried."""
from make_crew_portraits import portrait, CREW
from anim_core import add

def register():
    for cid in CREW:
        P = lambda w, e='open', m=None: portrait(cid, w, e, m).img()
        add('crew', f'crew_{cid}', 'idle_normal', [P(False), P(False, 'half'), P(False, 'closed'), P(False, 'half')],
            fps=8, durations=[20.0, 1.0, 1.0, 1.0], note='idle portrait, blinks every ~2.5 s')
        add('crew', f'crew_{cid}', 'talk_normal', [P(False, m=1), P(False, m=2), P(False, m=1), P(False, m=0),
                                                   P(False, m=2), P(False, m=0)],
            fps=10, note='talking (loop while the text appears; when done, go back to idle_normal)')
        add('crew', f'crew_{cid}', 'idle_worried', [P(True), P(True, 'half'), P(True, 'closed'), P(True, 'half'),
                                                    P(True), P(True, 'closed')],
            fps=8, durations=[10.0, 1.0, 1.0, 1.0, 2.0, 1.0], note='worried, blinks more often and twice')
        add('crew', f'crew_{cid}', 'talk_worried', [P(True, m=1), P(True, m=2), P(True, m=1), P(True, m=0),
                                                    P(True, m=2), P(True, m=0)],
            fps=10, note='talking, worried')
